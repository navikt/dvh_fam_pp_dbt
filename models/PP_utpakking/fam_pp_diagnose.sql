{{
    config(
        materialized='incremental'
    )
}}

with pp_meta_data as (
  select * from {{ref ('pp_meldinger_til_aa_pakke_ut')}}
),

pp_fagsak as (
  select * from {{ ref ('fam_pp_fagsak') }}
),

pre_final as (
select * from pp_meta_data,
  json_table(melding, '$'
    columns (
      vedtaks_tidspunkt  varchar2 path '$.vedtakstidspunkt'
     ,nested path '$.diagnosekoder[*]' columns (
      kode varchar2 path '$.kode'
     ,type varchar2 path '$.type'
      )
    )
  ) j
  where kode is not null
),

pre_final2 as (
  select p.kode
        ,p.type
        ,f.pk_pp_fagsak as fk_pp_fagsak
        ,f.forrige_behandlings_id, f.behandlings_id, f.saksnummer
        ,f.vedtaks_tidspunkt
  from pre_final p
  join pp_fagsak f
  on p.kafka_offset = f.kafka_offset
),
diagnose_fagsak_alle AS (
select ny.saksnummer,ny.behandlings_id siste_behandlings_id,fagsak_tidligere.behandlings_id,diagnose_tidligere.type,diagnose_tidligere.kode
  from pre_final2 ny
  left outer join pp_fagsak fagsak_tidligere On
  ny.saksnummer=fagsak_tidligere.saksnummer and
  ny.vedtaks_tidspunkt > fagsak_tidligere.vedtaks_tidspunkt
  join fam_pp_diagnose diagnose_tidligere on
  diagnose_tidligere.fk_pp_fagsak=fagsak_tidligere.pk_pp_fagsak
  and  diagnose_tidligere.type=ny.type
  and diagnose_tidligere.kode=ny.kode
  UNION ALL
  select saksnummer,behandlings_id siste_behandlings_id ,behandlings_id,type,kode from
  pre_final2
)
,ny_diagnose as
(
  select saksnummer,siste_behandlings_id ,type,kode, count(distinct behandlings_id) antall_behandlinger
  from diagnose_fagsak_alle
  group by  saksnummer,siste_behandlings_id ,type,kode
 
),
min_antall as
(
select siste_behandlings_id ,min(antall_behandlinger) min_antall_behandlinger,max(antall_behandlinger)  max_antall_behandlinger from ny_diagnose
group by siste_behandlings_id
 
)
,
final as
(
  select ny.*
         , antall_behandlinger antall_behandlinger
         ,min_antall.min_antall_behandlinger
         ,case  when nvl(antall_behandlinger,0)=0 then 'J'
                when  antall_behandlinger <= min_antall.min_antall_behandlinger then 'J'
         else 'N' end siste_diagnose_flagg
  from pre_final2 ny
  left join ny_diagnose
  on ny.saksnummer = ny_diagnose.saksnummer
  and ny.kode = ny_diagnose.kode
  and ny.type = ny_diagnose.type
  left join min_antall on
  min_antall.siste_behandlings_id = ny_diagnose.siste_behandlings_id
),

fk_diagnose as (
select
    f.*,
    pk_dim_diagnose fk_dim_diagnose
    from final f
      join dt_p.dim_diagnose
      on f.kode = dim_diagnose.diagnose_kode
      and f.type = upper(dim_diagnose.diagnose_tabell)
      and f.vedtaks_tidspunkt between dim_diagnose.gyldig_fra_dato and dim_diagnose.gyldig_til_dato
)

select
  dvh_fampp_kafka.hibernate_sequence.nextval as pk_pp_diagnose
  ,kode
  ,type
  ,fk_pp_fagsak
  ,localtimestamp as lastet_dato
  ,fk_dim_diagnose
  ,siste_diagnose_flagg
from fk_diagnose
 