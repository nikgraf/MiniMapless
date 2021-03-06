Smalltalk createPackage: 'MiniMapless-Tests'!
TestCase subclass: #MaplessLocalTest
	instanceVariableNames: ''
	package: 'MiniMapless-Tests'!

!MaplessLocalTest methodsFor: 'tests'!

testFresh

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 42.
	createdOne localSave.
	
	self shouldnt: [
			loadedOne := Mapless localFindId: createdOne id.
			loadedOne remember: 'something'.
			self assert: loadedOne remember = 'something'.
			loadedOne localFresh.
			self deny: loadedOne remember = 'something'.
			self assert: loadedOne remember = 42.
		] raise: Error
!

testLocalUpdate

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 'something'.
	
	self deny: (window localStorage getItem: createdOne id) notNil.
	
	createdOne localSave.

	self assert: (window localStorage getItem: createdOne id) notNil.

	self shouldnt: [
			loadedOne := Mapless localFindId: createdOne id.
			
			self assert: loadedOne class = Thing.
			self assert: loadedOne id = createdOne id.
			self assert: loadedOne remember = 'something'.
			self deny: loadedOne remember = 'else'.
			loadedOne remember: 'else'.
			self assert: loadedOne remember = 'else'.
			loadedOne localSave.
			loadedOne := Mapless localFindId: createdOne id.
			self deny: loadedOne remember = 'something'.
			self assert: loadedOne remember = 'else'.
		] raise: Error
!

testSaveAndDelete

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 'something'.
	
	self deny: (window localStorage getItem: createdOne id) notNil.
	
	createdOne localSave.

	self shouldnt: [
		self assert: (window localStorage getItem: createdOne id) notNil.
		loadedOne := Mapless localFindId: createdOne id.
		self assert: loadedOne remember = 'something'.
		
		loadedOne localDelete.
		self assert: (window localStorage getItem: createdOne id) isNil.
		self assert: (Mapless localFindId: createdOne id) isNil.
		] raise: Error
!

testSaveAndFindOne

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 'something'.
	
	self deny: (window localStorage getItem: createdOne id) notNil.
	
	createdOne localSave.

	self assert: (window localStorage getItem: createdOne id) notNil.

	self shouldnt: [
			loadedOne := Mapless localFindId: createdOne id.
			self assert: loadedOne class = Thing.
			self assert: loadedOne id = createdOne id.
			self assert: loadedOne remember = 'something'.
		] raise: Error
!

testSaveComposedMany

	| createdOne composed1 composed2 loadedOne part1 part2 |
	
	createdOne := Thing new.
	composed1 := Stuff new.
	composed2 := Thing new.
	
	createdOne remember: 'something'.
	
	self deny: (window localStorage getItem: createdOne id) notNil.
	
	composed1 localSave.
	composed2 localSave.
	createdOne
		parts: (Array new
					add: composed1;
					add: composed2;
					yourself);
		localSave.

	self shouldnt: [
		self assert: (window localStorage getItem: createdOne id) notNil.
		loadedOne := Mapless localFindId: createdOne id.
		part1 := Mapless localFindId: composed1 id.
		part2 := Mapless localFindId: composed2 id.
		self assert: loadedOne remember = 'something'.
		self assert: loadedOne parts first class = composed1 class.
		self assert: loadedOne parts first class = part1 class.
		self assert: loadedOne parts first id = part1 id.

		self assert: loadedOne parts second class = composed2 class.
		self assert: loadedOne parts second class = part2 class.
		self assert: loadedOne parts second id = part2 id.

		loadedOne localDelete.
		composed1 localDelete.
		composed2 localDelete.
		self assert: (window localStorage getItem: createdOne id) isNil.
		self assert: (window localStorage getItem: composed1 id) isNil.
		self assert: (window localStorage getItem: composed2 id) isNil.
		self assert: (Mapless localFindId: createdOne id) isNil.
		self assert: (Mapless localFindId: composed1 id) isNil.
		self assert: (Mapless localFindId: composed2 id) isNil.
		] raise: Error
!

testSaveComposedOne

	| createdOne composedOne loadedOne part |
	
	createdOne := Thing new.
	composedOne := Stuff new.
	
	createdOne remember: 'something'.
	
	self deny: (window localStorage getItem: createdOne id) notNil.
	
	composedOne localSave.
	createdOne 
		hasOneOf: composedOne;
		localSave.

	self shouldnt: [
		self assert: (window localStorage getItem: createdOne id) notNil.
		loadedOne := Mapless localFindId: createdOne id.
		part := Mapless localFindId: composedOne id.
		self assert: loadedOne remember = 'something'.
		self assert: loadedOne hasOneOf class = composedOne class.
		self assert: loadedOne hasOneOf class = part class.
		self assert: loadedOne hasOneOf id = part id.
		
		loadedOne localDelete.
		composedOne localDelete.
		self assert: (window localStorage getItem: createdOne id) isNil.
		self assert: (window localStorage getItem: composedOne id) isNil.
		self assert: (Mapless localFindId: createdOne id) isNil.
		self assert: (Mapless localFindId: composedOne id) isNil.
		] raise: Error
! !

TestCase subclass: #MaplessRemoteTest
	instanceVariableNames: ''
	package: 'MiniMapless-Tests'!

!MaplessRemoteTest methodsFor: 'tests'!

testCreate

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 'something'.
		
	createdOne createDo:[ :res |
		self shouldnt: [
				createdOne onAfterCreated: res.
				self assert: res status = 201 ]
			raise: MaplessError. 

		createdOne createDo:[ :resp |
		[ createdOne onAfterCreated: resp ]
			on: MaplessError
			do:[ :x | self assert: resp status = 409 ] ]
	].
!

testDelete

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne remember: 'something'.
		
	createdOne createDo:[ :res |
		self shouldnt: [
				createdOne onAfterCreated: res.
				self assert: res status = 201 ]
			raise: MaplessError. 

		createdOne deleteDo:[ :resp |
			createdOne onAfterDeleted: resp.
			self assert: resp status = 200 ].	
			
		Thing findId: createdOne id do:[ :response |
			response status = 404 ]
	].
!

testRead

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne 
		remember: 'something';
		remarkable: 'today';
		youself.
		
	createdOne createDo:[ :res |
		self shouldnt: [
				createdOne onAfterCreated: res.
				self assert: res status = 201 ]
			raise: MaplessError. 
			
		Thing findId: createdOne id do:[ :response | 
			loadedOne := Thing onAfterRead: response.
			self assert: loadedOne class = Thing.
			self assert: loadedOne remember = 'something'.
			self assert: loadedOne remarkable = 'today'
		]
	].
!

testReadAll

	| createdOne loadedOnes |
	
	createdOne := Thing new.
	
	createdOne 
		remember: 'something';
		remarkable: 'today';
		youself.
		
	createdOne createDo:[ :res |
		self shouldnt: [
				createdOne onAfterCreated: res.
				self assert: res status = 201 ]
			raise: MaplessError. 
	
		Thing findAllDo:[ :response |
			loadedOnes := Thing onAfterReadAll: response.
			self assert: (loadedOnes allSatisfy:[ :e | e class = Thing ]).
			self assert: (loadedOnes allSatisfy:[ :e | e id notNil ]).
			self assert: (loadedOnes anySatisfy:[ :e | e id = createdOne id ]).
			self assert: (loadedOnes anySatisfy:[ :e | e = createdOne ]).
			].
	]
!

testReadSome

	| createdOne query loadedOnes |
	
	createdOne := Thing new.
	
	createdOne 
		remember: 'some';
		youself.
		
	createdOne createDo:[ :res |
		self shouldnt: [
				createdOne onAfterCreated: res.
				self assert: res status = 201 ]
			raise: MaplessError. 

		query := '{"remember":"some"}'.
		
		Thing find: query do:[ :response |
			loadedOnes := Thing onAfterReadSome: response.
			self assert: (loadedOnes allSatisfy:[ :e | e class = Thing ]).
			self assert: (loadedOnes allSatisfy:[ :e | e id notNil ]).
			self assert: (loadedOnes anySatisfy:[ :e | e id = createdOne id ]).
			self assert: (loadedOnes anySatisfy:[ :e | e = createdOne ]).
			].
	]
!

testSave

	| createdOne loadedOne |
	
	createdOne := Thing new.
	
	createdOne 
		thereIs: 'noMap';
		in: 'mapless';
		yourself.
		
	createdOne saveDo:[ :res |
		self shouldnt: [
				createdOne onAfterSaved: res.
				self assert: res status = 200 ]
			raise: MaplessError.

		createdOne createDo:[ :resp |
		[ createdOne onAfterCreated: resp ]
			on: MaplessError
			do:[ :x | self assert: resp status = 409 ] ].
		
		Thing findId: createdOne id do:[ :response | 
			loadedOne := Thing onAfterRead: response.
			self assert: loadedOne class = Thing.
			self assert: loadedOne thereIs = 'noMap'.
			self assert: loadedOne in = 'mapless'
		]
	].
!

testUpdate

	| createdOne loadedOne updatedOne |
	
	createdOne := Thing new.
	
	createdOne thereIs: 'noMap'.
		
	createdOne saveDo:[ :res |
		self shouldnt: [
				createdOne onAfterSaved: res.
				self assert: res status = 200 ]
			raise: MaplessError.

		createdOne createDo:[ :resp |
		[ createdOne onAfterCreated: resp ]
			on: MaplessError
			do:[ :x | self assert: resp status = 409 ] ].
		
		Thing findId: createdOne id do:[ :response | 
			loadedOne := Thing onAfterRead: response.			
			self assert: loadedOne class = Thing.
			self assert: loadedOne thereIs = 'noMap'.

			loadedOne thereIs: 'LOLWAT?'.
			self assert: createdOne thereIs = 'noMap'.
			self assert: loadedOne thereIs = 'LOLWAT?'.
		
			loadedOne saveDo:[ :aResponse | loadedOne onAfterSave: aResponse.
				Thing findId: loadedOne id do:[ :aResp |
					updatedOne := Thing onAfterRead: aResp.
					self assert: updatedOne id = loadedOne id.
					self assert: updatedOne id = createdOne id.
					self assert: updatedOne thereIs = 'LOLWAT?'.
					self assert: updatedOne = loadedOne.
					self assert: createdOne = updatedOne.
					self deny: createdOne thereIs = updatedOne thereIs.
					self assert: loadedOne thereIs = updatedOne thereIs.
				] 
			]
		].
	]
! !

TestCase subclass: #MaplessSharedTest
	instanceVariableNames: ''
	package: 'MiniMapless-Tests'!

!MaplessSharedTest methodsFor: 'tests'!

testPath

	self deny: Thing path = 'api/1.0/thing'.
	self assert: Thing path = 'api/1.0/things'.

	"ok, but what about irregulars?"
	self assert: Stuff path = 'api/1.0/stuff'.
!

testURI
	| thing |
	
	thing := Thing new.
	
	self assert: thing id notNil.
	
	self assert: thing uri = ('api/1.0/things/', thing id)
! !

MaplessModel subclass: #Stuff
	instanceVariableNames: ''
	package: 'MiniMapless-Tests'!

!Stuff methodsFor: 'accessing'!

things

	^ super things ifNil:[ 
		self data at: 'things' put: Array new.
		self things ]
! !

!Stuff class methodsFor: 'accessing'!

pluralName

	^ 'stuff'
! !

MaplessModel subclass: #Thing
	instanceVariableNames: ''
	package: 'MiniMapless-Tests'!

