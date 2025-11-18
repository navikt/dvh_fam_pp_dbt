COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.PK_PP_DIAGNOSE IS '#NAVN PK_PP_DIAGNOSE #INNHOLD Primærnøkkel er en unik ID for hver rad, autogenerert fra dvh_fampp_kafka.hibernate_sequence.nextval';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.FK_PP_FAGSAK IS '#NAVN FK_PP_FAGSAK #INNHOLD Fremmednøkkel til fagsak tabellen (vedtaket)';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.LASTET_DATO IS '#NAVN LASTET_DATO #INNHOLD Tidsstempel som angir når en rad ble lagt til i tabellen';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.FK_DIM_DIAGNOSE IS '#NAVN FK_DIM_DIAGNOSE #INNHOLD Fremmednøkkel til diagnosen i DIM_DIAGNOSE tabellen';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.SISTE_DIAGNOSE_FLAGG IS '#NAVN SISTE_DIAGNOSE_FLAGG #INNHOLD Flagg (0/1) som angir om diagnosen er den siste/nyeste diagnosen for en pleietrengende';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.KODE IS '#NAVN KODE #INNHOLD En unik kode for en bestemt diagnose';
COMMENT ON COLUMN DVH_FAM_PP.FAM_PP_DIAGNOSE.TYPE IS '#NAVN TYPE #INNHOLD Europisk standardaren for diagnosene';