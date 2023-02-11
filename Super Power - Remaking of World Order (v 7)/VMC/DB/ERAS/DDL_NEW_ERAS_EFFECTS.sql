create table Era_MountainCityYieldChanges (
	EraType text not null REFERENCES Eras(Type),
	YieldType text not null REFERENCES Yields(Type),
	Yield integer not null
);