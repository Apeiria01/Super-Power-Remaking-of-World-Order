INSERT INTO HandicapInfo_Goodies SELECT HandicapInfos.Type, GoodyHuts.Type FROM HandicapInfos, GoodyHuts;

CREATE TABLE IDRemapper ( id INTEGER PRIMARY KEY AUTOINCREMENT, Type TEXT );
INSERT INTO IDRemapper (Type) SELECT Type FROM GoodyHuts ORDER BY ID ASC;
UPDATE GoodyHuts SET ID =	( SELECT IDRemapper.id-1 FROM IDRemapper WHERE GoodyHuts.Type = IDRemapper.Type);

DROP TABLE IDRemapper;