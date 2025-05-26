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
        --,p.vedtaks_tidspunkt
        ,f.pk_pp_fagsak as fk_pp_fagsak
        ,f.forrige_behandlings_id, f.behandlings_id, f.saksnummer
        ,f.vedtaks_tidspunkt
  from pre_final p
  join pp_fagsak f
  on p.kafka_offset = f.kafka_offset
),
 
ny_diagnose as
(
  select ny.saksnummer,diagnose_tidligere.type,diagnose_tidligere.kode, count(distinct fagsak_tidligere.behandlings_id) antall_behandlinger
  from pre_final2 ny
  left outer join pp_fagsak fagsak_tidligere On
  ny.saksnummer=fagsak_tidligere.saksnummer and
  ny.vedtaks_tidspunkt>fagsak_tidligere.vedtaks_tidspunkt
 
  left outer join fam_pp_diagnose diagnose_tidligere on
  diagnose_tidligere.fk_pp_fagsak=fagsak_tidligere.pk_pp_fagsak
  and  diagnose_tidligere.type=ny.type
  and diagnose_tidligere.kode=ny.kode
  group by  ny.saksnummer,diagnose_tidligere.type,diagnose_tidligere.kode
),
 
min_antall as
(
select min(antall_behandlinger) min_antall_behandlinger from ny_diagnose
)
,
final as
(
  select ny.*
         , nvl(antall_behandlinger,0) antall_behandlinger
         ,min_antall.min_antall_behandlinger
         ,case when nvl(antall_behandlinger,0)<=min_antall_behandlinger then 'J' else 'N' end siste_diagnose_flagg
        
  from pre_final2 ny
  left join ny_diagnose
  on ny.saksnummer = ny_diagnose.saksnummer
  and ny.kode = ny_diagnose.kode
  and ny.type = ny_diagnose.type
 
  left join min_antall on
  1=1
 
)
 
select
dvh_fampp_kafka.hibernate_sequence.nextval as pk_pp_diagnose,
kode,
type
,fk_pp_fagsak
,localtimestamp as lastet_dato
,cast(null as varchar2(4)) as fk_dim_diagnose
--,antall_behandlinger
--,min_antall_behandlinger
,siste_diagnose_flagg
from final