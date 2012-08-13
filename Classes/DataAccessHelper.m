/*  DataAccessHelper.m
 *  Presence
 *
 *  Created by Adam Duke on 8/1/10.
 *  Copyright 2010 Adam Duke. All rights reserved.
 *
 */

#import "DataAccessHelper.h"
#import "FMDatabase.h"
#import "Status.h"
#import "User.h"

@interface DataAccessHelper ()

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic, strong) NSString *documentsDatabasePath;

- (FMDatabase *)openApplicationDatabase;
- (void)updateSchema;
- (void)executeSqlOnAllTables:(NSString *)sql;
- (NSArray *)getTableNames;
- (void)dropAllTables;
- (BOOL)saveUser:(User *)user inDatabase:(FMDatabase *)database;
- (BOOL)updateUser:(User *)user inDatabase:(FMDatabase *)database;

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

/* Override the default initalizer to set up the instance variables needed for database operations
 */
- (DataAccessHelper *)init
{
    if(self = [super init])
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

/* save a User object's details to the database */
- (BOOL)saveOrUpdateUser:(User *)user
{
    BOOL saveOrUpdateResult = NO;

    /* open the database */
    FMDatabase *database = [self openApplicationDatabase];

    /* attempt to select a record based on the username */
    FMResultSet *resultSet = [database executeQuery:@"SELECT id "
                                                    " FROM   User "
                                                    " WHERE  user_id = ?", user.user_id];

    /* if the resultset contains a record this is an update */
    if([resultSet next])
    {
        saveOrUpdateResult = [self updateUser:user inDatabase:database];
    }

    /* if the resultset does not contain a record this is an insert */
    else
    {
        saveOrUpdateResult = [self saveUser:user inDatabase:database];
    }

    /* close the resultset and database */
    [resultSet close];
    [database close];

    return saveOrUpdateResult;
}

- (BOOL)updateUser:(User *)user inDatabase:(FMDatabase *)database
{
    [database beginTransaction];
    [database executeUpdate:@"UPDATE User "
                            " SET    screen_name = ?, "
                            "        display_name = ?, "
                            "        location = ?, "
                            "        description = ?, "
                            "        url = ? "
                            " WHERE  user_id = ?",
     user.screen_name,
     user.display_name,
     user.display_location,
     user.display_description,
     user.display_url,
     user.user_id];

    [database executeUpdate:@"UPDATE Image "
                            " SET    profile_image_url = ?, "
                            "        image = ? "
                            " WHERE  user_id = ?",
     user.profile_image_url,
     UIImagePNGRepresentation(user.image),
     user.user_id];
    [database commit];
    if(![database hadError])
    {
        return YES;
    }
    return NO;
}

- (BOOL)saveUser:(User *)user inDatabase:(FMDatabase *)database
{
    [database beginTransaction];
    [database executeUpdate:@"INSERT INTO User "
                            "             (user_id, "
                            "             screen_name, "
                            "             display_name, "
                            "             location, "
                            "             description, "
                            "             url) "
                            "VALUES (?, ?, ?, ?, ?, ?)",
     user.user_id,
     user.screen_name,
     user.display_name,
     user.display_location,
     user.display_description,
     user.display_url];

    [database executeUpdate:@"INSERT INTO Image "
                            "             (profile_image_url, "
                            "             user_id, "
                            "             image) "
                            "VALUES (?,?,?)",
     user.profile_image_url,
     user.user_id,
     UIImagePNGRepresentation(user.image)];
    [database commit];
    if(![database hadError])
    {
        return YES;
    }
    return NO;
}

/*
 * Attempt to initialize and populate a User object using data in the database for the given
 * userId
 */
- (User *)userByUserId:(NSString *)user_id
{
    /* open the database */
    FMDatabase *database = [self openApplicationDatabase];

    User *user = [[User alloc] init];

    /* query the database for the User's details */
    FMResultSet *resultSet = [database executeQuery:@"SELECT user.user_id, "
                                                    "        user.screen_name, "
                                                    "        user.display_name, "
                                                    "        user.location, "
                                                    "        user.description, "
                                                    "        user.url, "
                                                    "        image_table.profile_image_url, "
                                                    "        image_table.image "
                                                    " FROM   User user "
                                                    " JOIN   Image image_table "
                                                    "   ON   image_table.user_id = user.user_id "
                                                    "WHERE   user.user_id = ?", user_id];

    /* if the resultset contains data, construct a user object from it */
    while([resultSet next])
    {
        user.user_id = user_id;
        user.screen_name = [resultSet stringForColumn:@"screen_name"];
        user.display_name = [resultSet stringForColumn:@"display_name"];
        user.display_location = [resultSet stringForColumn:@"location"];
        user.display_description = [resultSet stringForColumn:@"description"];
        user.display_url = [resultSet stringForColumn:@"url"];
        user.profile_image_url = [resultSet stringForColumn:@"profile_image_url"];
        user.image = [UIImage imageWithData:[resultSet dataForColumn:@"image"]];
    }

    /* close the resultset and database */
    [resultSet close];
    [database close];

    /* return the user */
    return user;
}

/* Attempt to retrieve an image from the database for the given userId. The image data is stored in
 * a blob type
 */
- (UIImage *)imageForUserId:(NSString *)user_id
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