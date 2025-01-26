INSERT INTO Audio_Sounds 
		    (SoundID, 					    Filename, 			        LoadType)
VALUES      ('SND_SATELLITE_CANNON_SP',    'SatelliteCannon',			'DynamicResident');


INSERT INTO Audio_2DSounds 
		    (ScriptID, 							SoundID, 					    SoundType, 	    MinVolume, 	MaxVolume,	IsMusic)
VALUES      ('AS2D_SATELLITE_CANNON_SP',	    'SND_SATELLITE_CANNON_SP',		'GAME_SFX',	    65,			65,			0);