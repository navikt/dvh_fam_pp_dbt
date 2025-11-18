
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.PK_PP_RELASJONER IS '#NAVN PK_PP_RELASJONER #INNHOLD Primærnøkkel er en unik ID for hver rad, autogenerert fra dvh_fampp_kafka.hibernate_sequence.nextval';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.DATO_FOM IS '#NAVN DATO_FOM #INNHOLD Datoen relasjoen mottakeren har til pleiepengerutbetalingen gjelder fra (for en aktuell periode)';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.DATO_TOM IS '#NAVN DATO_TOM #INNHOLD Datoen relasjoen mottakeren har til pleiepengerutbetalingen gjelder til (for en aktuell periode)';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.FK_PP_FAGSAK IS '#NAVN FK_PP_FAGSAK #INNHOLD Fremmednøkkel til fagsak tabellen (vedtaket)';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.LASTET_DATO IS '#NAVN LASTET_DATO #INNHOLD Tidsstempel som angir når en rad ble lagt til i tabellen';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_RELASJONER.KODE IS '#NAVN KODE #INNHOLD Relasjonen mottakeren/søkeren har til pleietrengende på den aktuelle perioden';