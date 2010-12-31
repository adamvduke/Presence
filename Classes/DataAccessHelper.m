/*  DataAccessHelper.m
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "DataAccessHelper.h"
#import "FMDatabase.h"
#import "Person.h"
#import "Status.h"

@interface DataAccessHelper ()

@property (nonatomic, retain) NSString *databaseName;
@property (nonatomic, retain) NSString *documentsDatabasePath;

- (FMDatabase *)openApplicationDatabase;
- (void)updateSchema;
- (void)executeSqlOnAllTables:(NSString *)sql;
- (NSArray *)getTableNames;
- (void)dropAllTables;
- (BOOL)savePerson:(Person *)person inDatabase:(FMDatabase *)database;
- (BOOL)updatePerson:(Person *)person inDatabase:(FMDatabase *)database;

@end

@implementation DataAccessHelper

@synthesize databaseName, documentsDatabasePath;

/* local constants */
NSString *const CurrentSchemaVersion = @"CurrentSchemaVersion";
NSString *const SchemaVersionFormatString = @"Schema_Version_%d";

#pragma mark -
#pragma mark NSObject

/* Release memory that is being held in any instance variables during deconstruction
 */
- (void)dealloc
{
	[databaseName release];
	[documentsDatabasePath release];
	[super dealloc];
}

/* Override the default initalizer to set up the instance variables needed for database operations
 */
- (DataAccessHelper *)init
{
	if(self == [super init])
	{
		/* Hold on to the path to the documents directory */
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectoryPath = [documentPaths objectAtIndex:0];

		/* Hold on to the paths for the SchemaVersions.plis and Presence.db files */
		self.documentsDatabasePath = [documentsDirectoryPath stringByAppendingPathComponent:@"Presence.db"];
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

/* create the default database and save it in the Documents directory */
- (BOOL)createAndValidateDatabase
{
	FMDatabase *database = [self openApplicationDatabase];

	/* update the schema */
	[self updateSchema];

	[database close];
	return YES;
}

/* delete any data that has been stored in the database */
- (void)deleteAllData
{
	[self executeSqlOnAllTables:@"DELETE FROM %@"];
	[self dropAllTables];
}

/* save a Person object's details to the database */
- (BOOL)saveOrUpdatePerson:(Person *)person
{
	BOOL saveOrUpdateResult = NO;

	/* open the database */
	FMDatabase *database = [self openApplicationDatabase];

	/* attempt to select a record based on the username */
	FMResultSet *resultSet = [database executeQuery:@"SELECT id "
	                                                " FROM   Person "
	                                                " WHERE  user_id = ?", person.user_id];
	/* if the resultset contains a record this is an update */
	if([resultSet next])
	{
		saveOrUpdateResult = [self updatePerson:person inDatabase:database];
	}

	/* if the resultset does not contain a record this is an insert */
	else
	{
		saveOrUpdateResult = [self savePerson:person inDatabase:database];
	}

	/* close the resultset and database */
	[resultSet close];
	[database close];

	return saveOrUpdateResult;
}

- (BOOL)updatePerson:(Person *)person inDatabase:(FMDatabase *)database
{
	[database beginTransaction];
	[database executeUpdate:@"UPDATE Person "
	                        " SET    screen_name = ?, "
	                        "        display_name = ?, "
	                        "        location = ?, "
	                        "        description = ?, "
	                        "        url = ? "
	                        " WHERE  user_id = ?",
	 person.screen_name,
	 person.display_name,
	 person.display_location,
	 person.display_description,
	 person.display_url,
	 person.user_id];

	[database executeUpdate:@"UPDATE Image "
	                        " SET    profile_image_url = ?, "
	                        "        image = ? "
	                        " WHERE  user_id = ?",
	 person.profile_image_url,
	 UIImagePNGRepresentation(person.image),
	 person.user_id];
	[database commit];
	if(![database hadError])
	{
		return YES;
	}
	return NO;
}

- (BOOL)savePerson:(Person *)person inDatabase:(FMDatabase *)database
{
	[database beginTransaction];
	[database executeUpdate:@"INSERT INTO Person "
	                        "             (user_id, "
	                        "             screen_name, "
	                        "             display_name, "
	                        "             location, "
	                        "             description, "
	                        "             url) "
	                        "VALUES (?, ?, ?, ?, ?, ?)",
	 person.user_id,
	 person.screen_name,
	 person.display_name,
	 person.display_location,
	 person.display_description,
	 person.display_url];

	[database executeUpdate:@"INSERT INTO Image "
	                        "             (profile_image_url, "
	                        "             user_id, "
	                        "             image) "
	                        "VALUES (?,?,?)",
	 person.profile_image_url,
	 person.user_id,
	 UIImagePNGRepresentation(person.image)];
	[database commit];
	if(![database hadError])
	{
		return YES;
	}
	return NO;
}

/*
 * Attempt to initialize and populate a Person object using data in the database for the given
 * userId
 */
- (Person *)initPersonByUserId:(NSString *)user_id
{
	/* open the database */
	FMDatabase *database = [self openApplicationDatabase];

	Person *person = [[Person alloc] init];

	/* query the database for the Person's details */
	FMResultSet *resultSet = [database executeQuery:@"SELECT person.user_id, "
	                                                "        person.screen_name, "
	                                                "        person.display_name, "
	                                                "        person.location, "
	                                                "        person.description, "
	                                                "        person.url, "
	                                                "        image_table.profile_image_url, "
	                                                "        image_table.image "
	                                                " FROM   Person person "
	                                                " JOIN   Image image_table "
	                                                "   ON   image_table.user_id = person.user_id "
	                                                "WHERE   person.user_id = ?", user_id];
	/* if the resultset contains data, construct a Person object from it */
	while([resultSet next])
	{
		person.user_id = user_id;
		person.screen_name = [resultSet stringForColumn:@"screen_name"];
		person.display_name = [resultSet stringForColumn:@"display_name"];
		person.display_location = [resultSet stringForColumn:@"location"];
		person.display_description = [resultSet stringForColumn:@"description"];
		person.display_url = [resultSet stringForColumn:@"url"];
		person.profile_image_url = [resultSet stringForColumn:@"profile_image_url"];
		person.image = [UIImage imageWithData:[resultSet dataForColumn:@"image"]];
	}

	/* close the resultset and database */
	[resultSet close];
	[database close];

	/* return the Person */
	return person;
}

/* Attempt to retrieve an image from the database for the given userId. The image data is stored in
 * a blob type
 */
- (UIImage *)initImageForUserId:(NSString *)user_id
{
	FMDatabase *database = [self openApplicationDatabase];
	FMResultSet *resultSet = [database executeQuery:@"SELECT image "
	                                                " FROM Image "
	                                                " WHERE user_id = ?", user_id];
	UIImage *returnImage = nil;
	if([resultSet next])
	{
		returnImage = [[UIImage alloc] initWithData:[resultSet dataForColumn:@"image"]];
	}
	return returnImage;
}

#pragma mark -
#pragma mark Private Methods

/* Convenience method to get a reference to an open FMDatabase object and log any associated erros
 */
- (FMDatabase *)openApplicationDatabase
{
	FMDatabase *database = [FMDatabase databaseWithPath:self.documentsDatabasePath];
	if(![database open])
	{
		NSLog(@"Error opening database.");
		if([database hadError])
		{
			NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
		}
	}
	return database;
}

/* Determines the current state of the database schema and applies the neccesary updates
 * to match the currently expected version by the application
 */
- (void)updateSchema
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

	/* get the current schema version */
	NSInteger currentVersion = [userDefaults integerForKey:CurrentSchemaVersion];

	/* a boolean to indicate the schema has changed */
	BOOL schemaUpdated = NO;

	NSString *fileName = [NSString stringWithFormat:SchemaVersionFormatString, currentVersion + 1];

	/* get the list of statements to make the DDL change */
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	while(path)
	{
		NSArray *sqlStatements = [NSArray arrayWithContentsOfFile:path];
		schemaUpdated = YES;

		/* open the database */
		FMDatabase *database = [self openApplicationDatabase];
		/* execute the statements */
		for(NSString *statement in sqlStatements)
		{
			[database executeUpdate:statement];
			if([database hadError])
			{
				NSLog(@"Err %d: %@", [database lastErrorCode], [database lastErrorMessage]);
			}
		}
		[database close];

		/* increment version */
		currentVersion++;
		[userDefaults setInteger:currentVersion forKey:CurrentSchemaVersion];
		fileName = [NSString stringWithFormat:SchemaVersionFormatString, currentVersion + 1];
		path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
	}
	/* if the schemaUpdated flag has flipped, we'll want to write out the NSUserDefaults
	 * because the CurrentSchemaVersion will have been updated
	 */
	if(schemaUpdated)
	{
		[userDefaults synchronize];
	}
}

/* Drops all the tables currently in the database
 */
- (void)dropAllTables
{
	[self executeSqlOnAllTables:@"DROP TABLE %@"];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:CurrentSchemaVersion];
	[defaults synchronize];
}

/* gets an NSArray of NSString's containing the names of current tables
 * added to the database
 */
- (NSArray *)getTableNames
{
	FMDatabase *database = [self openApplicationDatabase];
	FMResultSet *resultSet = [database executeQuery:@"SELECT DISTINCT tbl_name FROM sqlite_master"];
	NSMutableArray *tableNames = [NSMutableArray array];
	while([resultSet next])
	{
		[tableNames addObject:[resultSet stringForColumn:@"tbl_name"]];
	}
	[resultSet close];
	[database close];
	return tableNames;
}

/* Executes the sql statement against all tables retrieved from the
 * getTableNames method. The sql statement must have a %@ string format
 * specifier in the place of the table name
 */
- (void)executeSqlOnAllTables:(NSString *)sql
{
	FMDatabase *database = [self openApplicationDatabase];
	NSArray *tableNames = [self getTableNames];
	for(NSString *tableName in tableNames)
	{
		NSString *finalSql = [NSString stringWithFormat:sql, tableName];
		[database executeUpdate:finalSql];
	}
	[database close];
}

@end