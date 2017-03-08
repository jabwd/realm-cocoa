////////////////////////////////////////////////////////////////////////////
//
// Copyright 2017 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMTestCase.h"

#pragma mark - Test Objects

@interface DogExtraObject : RLMObject
@property NSString *dogName;
@property int age;
@property NSString *breed;
@end

@implementation DogExtraObject
@end

@interface BizzaroDog : RLMObject
@property int dogName;
@property NSString *age;
@end

@implementation BizzaroDog
@end


@interface PrimaryKeyWithLinkObject : RLMObject
@property NSString *primaryKey;
@property StringObject *string;
@end

//@implementation PrimaryKeyWithLinkObject
//+ (NSString *)primaryKey {
//    return @"primaryKey";
//}
//@end

#pragma mark - Tests

@interface ObjectCreationTests : RLMTestCase
@end

@implementation ObjectCreationTests

#pragma mark - Init With Value

- (void)testInitWithArray {
    auto co = [[CompanyObject alloc] initWithValue:@[]];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company"]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company", NSNull.null]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"empty company", @[]]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@[@"one employee",
                                                @[@[@"name", @2, @YES]]]];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);
}

- (void)testInitWithInvalidArray {
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@[@"name", @"age"]]),
                                      @"Invalid value 'age' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@[@"name", NSNull.null]]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@[@"name", @5, @"too many values"]]),
                                      @"Invalid array input: more values \\(3\\) than properties \\(2\\).");
}

- (void)testInitWithDictionary {
    auto co = [[CompanyObject alloc] initWithValue:@{}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": NSNull.null}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company"}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company",
                                                @"employees": NSNull.null}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"empty company",
                                                @"employees": @[]}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"one employee",
                                                @"employees": @[@[@"name", @2, @YES]]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"one employee",
                                                @"employees": @[@{@"name": @"name",
                                                                  @"age": @2,
                                                                  @"hired": @YES}]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [[CompanyObject alloc] initWithValue:@{@"name": @"no employees",
                                                @"extra fields": @"are okay"}];
    XCTAssertEqualObjects(co.name, @"no employees");
    XCTAssertEqual(co.employees.count, 0U);
}

- (void)testInitWithInvalidDictionary {
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@{@"name": @"a", @"age": NSNull.null}]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([[DogObject alloc] initWithValue:@{@"name": @"a", @"age": NSDate.date}]),
                                      @"Invalid value '20.*' for property 'age'");
}

- (void)testInitWithObject {
    auto eo = [[EmployeeObject alloc] init];
    eo.name = @"employee name";
    eo.age = 1;
    eo.hired = NO;

    auto co = [[CompanyObject alloc] init];
    co.name = @"name";
    [co.employees addObject:eo];

    auto co2 = [[CompanyObject alloc] initWithValue:co];
    XCTAssertEqualObjects(co.name, co2.name);
    XCTAssertEqual(co.employees[0], co2.employees[0]); // not EqualObjects as it's a shallow copy

    auto dogExt = [[DogExtraObject alloc] initWithValue:@[@"Fido", @12, @"Poodle"]];
    auto dog = [[DogObject alloc] initWithValue:dogExt];
    XCTAssertEqualObjects(dog.dogName, @"Fido");
    XCTAssertEqual(dog.age, 12);

    auto owner = [[OwnerObject alloc] initWithValue:@[@"Alex", dogExt]];
    XCTAssertEqualObjects(owner.dog.dogName, @"Fido");
}

- (void)testInitWithInvalidObject {
    RLMAssertThrowsWithReasonMatching([[DogObject alloc] initWithValue:self.nonLiteralNil],
                                      @"Must provide a non-nil value");
    RLMAssertThrowsWithReasonMatching([[DogObject alloc] initWithValue:@""],
                                      @"Invalid value '' to initialize object of type 'DogObject'");

    // No overlap in properties
    auto so = [[StringObject alloc] initWithValue:@[@"str"]];
    RLMAssertThrowsWithReasonMatching([[IntObject alloc] initWithValue:so], @"missing key 'intCol'");

    // Dog has some but not all of DogExtra's properties
    auto dog = [[DogObject alloc] initWithValue:@[@"Fido", @10]];
    RLMAssertThrowsWithReasonMatching([[DogExtraObject alloc] initWithValue:dog], @"missing key 'breed'");

    // Same property names, but different types
    RLMAssertThrowsWithReasonMatching([[BizzaroDog alloc] initWithValue:dog],
                                      @"Invalid value 'Fido' for property 'dogName'");
}

- (void)testInitWithCustomAccessors {
    // Create with array
    auto ca = [[CustomAccessorsObject alloc] initWithValue:@[@"a", @1]];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    // Create with dictionary
    ca = [[CustomAccessorsObject alloc] initWithValue:@{@"name": @"b", @"age": @2}];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);

    // Create with KVO-compatible object
    ca = [[CustomAccessorsObject alloc] initWithValue:ca];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);
}

- (void)testInitAllPropertyTypes {
    auto now = [NSDate date];
    auto bytes = [NSData dataWithBytes:"a" length:1];
    auto so = [[StringObject alloc] init];
    so.stringCol = @"string";
    auto ao = [[AllTypesObject alloc] initWithValue:@[@YES, @1, @1.1f, @1.11,
                                                      @"string", bytes,
                                                      now, @YES, @11, so]];
    XCTAssertEqual(ao.boolCol, YES);
    XCTAssertEqual(ao.intCol, 1);
    XCTAssertEqual(ao.floatCol, 1.1f);
    XCTAssertEqual(ao.doubleCol, 1.11);
    XCTAssertEqualObjects(ao.stringCol, @"string");
    XCTAssertEqualObjects(ao.binaryCol, bytes);
    XCTAssertEqual(ao.dateCol, now);
    XCTAssertEqual(ao.cBoolCol, true);
    XCTAssertEqual(ao.longCol, 11);
    XCTAssertEqual(ao.objectCol, so);

    auto opt = [[AllOptionalTypes alloc] initWithValue:@[NSNull.null, NSNull.null,
                                                         NSNull.null, NSNull.null,
                                                         NSNull.null, NSNull.null,
                                                         NSNull.null]];
    XCTAssertNil(opt.intObj);
    XCTAssertNil(opt.boolObj);
    XCTAssertNil(opt.floatObj);
    XCTAssertNil(opt.doubleObj);
    XCTAssertNil(opt.date);
    XCTAssertNil(opt.data);
    XCTAssertNil(opt.string);

    opt = [[AllOptionalTypes alloc] initWithValue:@[@1, @2.2f, @3.3, @YES,
                                                    @"str", bytes, now]];
    XCTAssertEqualObjects(opt.intObj, @1);
    XCTAssertEqualObjects(opt.boolObj, @YES);
    XCTAssertEqualObjects(opt.floatObj, @2.2f);
    XCTAssertEqualObjects(opt.doubleObj, @3.3);
    XCTAssertEqualObjects(opt.date, now);
    XCTAssertEqualObjects(opt.data, bytes);
    XCTAssertEqualObjects(opt.string, @"str");
}

#pragma mark - Create

- (void)testCreateWithArray {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto co = [CompanyObject createInRealm:realm withValue:@[@"empty company", NSNull.null]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@[@"empty company", @[]]];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@[@"one employee",
                                                        @[@[@"name", @2, @YES]]]];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    [realm cancelWriteTransaction];
}

- (void)testCreateWithInvalidArray {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", @"age"]]),
                                      @"Invalid value 'age' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", NSNull.null]]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@[@"name", @5, @"too many values"]]),
                                      @"Invalid array input: more values \\(3\\) than properties \\(2\\).");
    RLMAssertThrowsWithReasonMatching(([PrimaryStringObject createInRealm:realm withValue:@[]]),
                                      @"Invalid array input: primary key must be present.");

    [realm cancelWriteTransaction];
}

- (void)testCreateWithDictionary {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto co = [CompanyObject createInRealm:realm withValue:@{}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": NSNull.null}];
    XCTAssertNil(co.name);
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company"}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company",
                                                        @"employees": NSNull.null}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"empty company",
                                                        @"employees": @[]}];
    XCTAssertEqualObjects(co.name, @"empty company");
    XCTAssertEqual(co.employees.count, 0U);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"one employee",
                                                        @"employees": @[@[@"name", @2, @YES]]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    EmployeeObject *eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"one employee",
                                                        @"employees": @[@{@"name": @"name",
                                                                          @"age": @2,
                                                                          @"hired": @YES}]}];
    XCTAssertEqualObjects(co.name, @"one employee");
    XCTAssertEqual(co.employees.count, 1U);
    eo = co.employees.firstObject;
    XCTAssertEqualObjects(eo.name, @"name");
    XCTAssertEqual(eo.age, 2);
    XCTAssertEqual(eo.hired, YES);

    co = [CompanyObject createInRealm:realm withValue:@{@"name": @"no employees",
                                                        @"extra fields": @"are okay"}];
    XCTAssertEqualObjects(co.name, @"no employees");
    XCTAssertEqual(co.employees.count, 0U);
}

- (void)testCreateWithInvalidDictionary {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@{@"name": @"a", @"age": NSNull.null}]),
                                      @"Invalid value '<null>' for property 'age'");
    RLMAssertThrowsWithReasonMatching(([DogObject createInRealm:realm withValue:@{@"name": @"a", @"age": NSDate.date}]),
                                      @"Invalid value '20.*' for property 'age'");
}

- (void)testCreateWithObject {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto eo = [[EmployeeObject alloc] init];
    eo.name = @"employee name";
    eo.age = 1;
    eo.hired = NO;

    auto co = [[CompanyObject alloc] init];
    co.name = @"name";
    [co.employees addObject:eo];

    auto co2 = [CompanyObject createInRealm:realm withValue:co];
    XCTAssertEqualObjects(co.name, co2.name);
    // Deep copy, so it's a different object
    XCTAssertFalse([co.employees[0] isEqualToObject:co2.employees[0]]);
    XCTAssertEqualObjects(co.employees[0].name, co2.employees[0].name);

    auto dogExt = [DogExtraObject createInRealm:realm withValue:@[@"Fido", @12, @"Poodle"]];
    auto dog = [DogObject createInRealm:realm withValue:dogExt];
    XCTAssertEqualObjects(dog.dogName, @"Fido");
    XCTAssertEqual(dog.age, 12);

    auto owner = [OwnerObject createInRealm:realm withValue:@[@"Alex", dogExt]];
    XCTAssertEqualObjects(owner.dog.dogName, @"Fido");
}

- (void)testCreateWithInvalidObject {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    RLMAssertThrowsWithReasonMatching([DogObject createInRealm:realm withValue:self.nonLiteralNil],
                                      @"Must provide a non-nil value");
    RLMAssertThrowsWithReasonMatching([DogObject createInRealm:realm withValue:@""],
                                      @"Invalid value '' to initialize object of type 'DogObject'");

    // No overlap in properties
    auto so = [StringObject createInRealm:realm withValue:@[@"str"]];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:so], @"missing key 'intCol'");

    // Dog has some but not all of DogExtra's properties
    auto dog = [DogObject createInRealm:realm withValue:@[@"Fido", @10]];
    RLMAssertThrowsWithReasonMatching([DogExtraObject createInRealm:realm withValue:dog],
                                      @"missing key 'breed'");

    // Same property names, but different types
    RLMAssertThrowsWithReasonMatching([BizzaroDog createInRealm:realm withValue:dog],
                                      @"Invalid value 'Fido' for property 'dogName'");
}

- (void)testCreateAllPropertyTypes {
    auto realm = RLMRealm.defaultRealm;
    [realm beginWriteTransaction];

    auto now = [NSDate date];
    auto bytes = [NSData dataWithBytes:"a" length:1];
    auto so = [[StringObject alloc] init];
    so.stringCol = @"string";
    auto ao = [AllTypesObject createInRealm:realm withValue:@[@YES, @1, @1.1f, @1.11,
                                                              @"string", bytes,
                                                              now, @YES, @11, so]];
    XCTAssertEqual(ao.boolCol, YES);
    XCTAssertEqual(ao.intCol, 1);
    XCTAssertEqual(ao.floatCol, 1.1f);
    XCTAssertEqual(ao.doubleCol, 1.11);
    XCTAssertEqualObjects(ao.stringCol, @"string");
    XCTAssertEqualObjects(ao.binaryCol, bytes);
    XCTAssertEqualObjects(ao.dateCol, now);
    XCTAssertEqual(ao.cBoolCol, true);
    XCTAssertEqual(ao.longCol, 11);
    XCTAssertNotEqual(ao.objectCol, so);
    XCTAssertEqualObjects(ao.objectCol.stringCol, @"string");

    auto opt = [AllOptionalTypes createInRealm:realm withValue:@[NSNull.null, NSNull.null,
                                                                 NSNull.null, NSNull.null,
                                                                 NSNull.null, NSNull.null,
                                                                 NSNull.null]];
    XCTAssertNil(opt.intObj);
    XCTAssertNil(opt.boolObj);
    XCTAssertNil(opt.floatObj);
    XCTAssertNil(opt.doubleObj);
    XCTAssertNil(opt.date);
    XCTAssertNil(opt.data);
    XCTAssertNil(opt.string);

    opt = [AllOptionalTypes createInRealm:realm withValue:@[@1, @2.2f, @3.3, @YES,
                                                            @"str", bytes, now]];
    XCTAssertEqualObjects(opt.intObj, @1);
    XCTAssertEqualObjects(opt.boolObj, @YES);
    XCTAssertEqualObjects(opt.floatObj, @2.2f);
    XCTAssertEqualObjects(opt.doubleObj, @3.3);
    XCTAssertEqualObjects(opt.date, now);
    XCTAssertEqualObjects(opt.data, bytes);
    XCTAssertEqualObjects(opt.string, @"str");
}

- (void)testCreateWithInvalidatedObject {
    auto realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    auto obj1 = [IntObject createInRealm:realm withValue:@[@0]];
    auto obj2 = [IntObject createInRealm:realm withValue:@[@1]];
    auto obj1alias = [IntObject allObjectsInRealm:realm].firstObject;

    [realm deleteObject:obj1];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj1],
                                      @"Object has been deleted or invalidated.");
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj1alias],
                                      @"Object has been deleted or invalidated.");

    [realm commitWriteTransaction];
    [realm invalidate];
    [realm beginWriteTransaction];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:obj2],
                                      @"Object has been deleted or invalidated.");
    [realm cancelWriteTransaction];
}

- (void)testCreateOutsideWriteTransaction {
    auto realm = [RLMRealm defaultRealm];
    RLMAssertThrowsWithReasonMatching([IntObject createInRealm:realm withValue:@[@0]],
                                      @"call beginWriteTransaction");
}

- (void)testCreateInNilRealm {
    RLMAssertThrowsWithReasonMatching(([IntObject createInRealm:self.nonLiteralNil withValue:@[@0]]),
                                      @"Realm must not be nil");
}

- (void)testCreatingObjectWithoutAnyPropertiesThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrows([AbstractObject createInRealm:realm withValue:@[]]);
    [realm cancelWriteTransaction];
}

- (void)testCreateWithCustomAccessors {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    // Create with array
    auto ca = [CustomAccessorsObject createInRealm:realm withValue:@[@"a", @1]];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    // Create with dictionary
    ca = [CustomAccessorsObject createInRealm:realm withValue:@{@"name": @"b", @"age": @2}];
    XCTAssertEqualObjects(ca.name, @"b");
    XCTAssertEqual(ca.age, 2);

    // FIXME: doesn't work
    // Create with KVO-compatible object
//    auto ca2 = [CustomAccessorsObject createInRealm:realm withValue:ca];
//    XCTAssertEqualObjects(ca2.name, @"b");
//    XCTAssertEqual(ca2.age, 2);

    [realm cancelWriteTransaction];
}

#pragma mark - Create Or Update
#pragma mark - Add

- (void)testAddingObjectWithoutAnyPropertiesThrows {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    RLMAssertThrows([realm addObject:[[AbstractObject alloc] initWithValue:@[]]]);
    [realm cancelWriteTransaction];
}

- (void)testAddWithCustomAccessors {
    auto realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];

    auto ca = [[CustomAccessorsObject alloc] initWithValue:@[@"a", @1]];
    [realm addObject:ca];
    XCTAssertEqualObjects(ca.name, @"a");
    XCTAssertEqual(ca.age, 1);

    [realm cancelWriteTransaction];
}

#pragma mark - Add Or Update

- (void)testCreateOrUpdateSameRealm {
    RLMRealm *realm = self.realmWithTestPath;
    [realm beginWriteTransaction];
    PrimaryKeyWithLinkObject *object = [PrimaryKeyWithLinkObject createInRealm:realm withValue:@[@"", @[@""]]];
    PrimaryKeyWithLinkObject *returnedObject = [PrimaryKeyWithLinkObject createOrUpdateInRealm:realm withValue:object];
    XCTAssertEqual(object, returnedObject);
    [realm commitWriteTransaction];
}

- (void)testClassExtension {
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    BaseClassStringObject *bObject = [[BaseClassStringObject alloc ] init];
    bObject.intCol = 1;
    bObject.stringCol = @"stringVal";
    [realm addObject:bObject];
    [realm commitWriteTransaction];

    BaseClassStringObject *objectFromRealm = [BaseClassStringObject allObjects][0];
    XCTAssertEqual(1, objectFromRealm.intCol, @"Should be 1");
    XCTAssertEqualObjects(@"stringVal", objectFromRealm.stringCol, @"Should be stringVal");
}

@end
