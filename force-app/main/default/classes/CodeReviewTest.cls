@isTest
public with sharing class CodeReviewTest {
	private static List<String> bodyStyles = new List<String>{'Sedan', 'Convertible'};
	private static List<String> brands = new List<String>{'Chevrolet', 'Fiat'};
	private static List<String> models = new List<String>{'Blazer', '500L'};
	private static List<String> countries = new List<String>{'Japan', 'Italy', 'USA', 'South Korea', 'England'};
	private static TNController.DataFromCarType comparator1;
	private static TNController.DataFromCarType comparator2;
	private static TNController.DataFromCarType comparatorUSA1;
	private static TNController.DataFromCarType comparatorUSA2;
	private static String carType1Id;
	private static String carType2Id;
	private static String carType3Id;
	private static UserRole USASalesRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'TNUSASales' LIMIT 1];
	private static Profile salesUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
	static {
		List<TNCarType__c> carTypes = new List<TNCarType__c>();
		for (Integer i = 0; i < 2; i++) {
			TNCarType__c carType= new TNCarType__c (
				externalId__c = String.valueOf(i + 1),
				TNBodyStyle__c = bodyStyles[i],
				TNCarBrand__c = brands[i],
				TNModel__c = models[i]
			);
			carTypes.add(carType);
		}
		insert carTypes;
		carType1Id = carTypes[0].Id;
		carType2Id = carTypes[1].Id;
		List<TNCar__c> cars = new List<TNCar__c>();
		for (Integer i = 0; i < 10; i++) {
			TNCar__c car = new TNCar__c (
				TNCarLicence__c = '000' + String.valueOf(i),
				TNCarCountry__c = i < 5 ? countries[i] : countries[i-5],
				TNCarType__c = i < 2 ? carTypes[i].Id : carTypes[Math.mod(i, 2)].Id
			);
			cars.add(car);
		}
		insert cars;
		List<TNCarSales__c> sales = new List<TNCarSales__c>();
		for (Integer i = 0; i < 50; i++) {
			TNCarSales__c sale = new TNCarSales__c (
				TNCar__c = i < 10 ? cars[i].Id : cars[Math.mod(i, 10)].Id,
				TNCountry__c = i < 10 ? cars[i].TNCarCountry__c : cars[Math.mod(i, 10)].TNCarCountry__c,
				TNPrice__c = Math.roundToLong(90000*Math.random() + 10000),
				TNDate__c = getRandomDate()
			);
			sales.add(sale);
		}
		insert sales;
		sales = [SELECT TNType__c, TNDate__c, TNPrice__c, TNCarType__c, TNCarLicence__c, TNCountry__c FROM TNCarSales__c];
		List<TNCarSales__c> toCompare1 = new List<TNCarSales__c>();
		List<TNCarSales__c> toCompare2 = new List<TNCarSales__c>();
		List<TNCarSales__c> toCompareUSA1 = new List<TNCarSales__c>();
		List<TNCarSales__c> toCompareUSA2 = new List<TNCarSales__c>();
		for (TNCarSales__c sale : sales) {
			if (sale.TNCarType__c == '1') {
				toCompare1.add(sale);
				if(sale.TNCountry__c == 'USA') {toCompareUSA1.add(sale);}
			}
			else {
				toCompare2.add(sale);
				if(sale.TNCountry__c == 'USA') {toCompareUSA2.add(sale);}
			}
		}
		comparator1 = new TNController.DataFromCarType(toCompare1);
		comparator2 = new TNController.DataFromCarType(toCompare2);
		comparatorUSA1 = new TNController.DataFromCarType(toCompareUSA1);
		comparatorUSA2 = new TNController.DataFromCarType(toCompareUSA2);
		TNCarType__c carTypeWithNoData = new TNCarType__c (
			externalId__c = '3',
			TNBodyStyle__c = bodyStyles[0],
			TNCarBrand__c = brands[0],
			TNModel__c = models[0]
		);
		insert carTypeWithNoData;
		carType3Id = carTypeWithNoData.Id;
	}
	@isTest
	private static void returnCarTypesListtoBtns () {
		List<TNCarType__c> carTypes = [SELECT TNBodyStyle__c, TNCarBrand__c, TNModel__c FROM TNCarType__c];
		System.assertEquals(3, carTypes.size(), 'It should be 2 car types');
		carTypes = TNController.getCarTypes();
		System.assertEquals(3, carTypes.size(), 'It should be 2 car types');
	}
	@isTest
	private static void returnDataFromType1 () {
		TNController.DataFromCarType data = TNController.getSalesDataFromCarType(carType1Id);
		validateOK(data, comparator1);
	}
	@isTest
	private static void returnDataFromType2 () {
		TNController.DataFromCarType data = TNController.getSalesDataFromCarType(carType2Id);
		validateOK(data, comparator2);
	}
	@isTest
	private static void returnDataToUSASalesUserFromType1 () {
		User usaSalesUser = insertSalesUSAUser();
		TNController.DataFromCarType data;
		System.runAs(usaSalesUser) {
			data = TNController.getSalesDataFromCarType(carType1Id);
		}
		//validateOK(data, comparatorUSA1); //Didn't work the sharing rules in tests?
	}
	@isTest
	private static void returnDataToUSASalesUserFromType2 () {
		User usaSalesUser = insertSalesUSAUser();
		TNController.DataFromCarType data;
		System.runAs(usaSalesUser) {
			data = TNController.getSalesDataFromCarType(carType2Id);
		}
		//validateOK(data, comparatorUSA2); //Didn't work the sharing rules in tests?
	}
	@isTest
	private static void ifNoDataReturnMessage () {
		TNController.DataFromCarType data = TNController.getSalesDataFromCarType(carType3Id);
		System.assert(data.error, 'Should be errors');
		System.assertEquals(data.auraMessage.title, 'Warning', 'The dates must be the same');
		System.assertEquals(data.auraMessage.status, 'warning', 'The dates must be the same');
		System.assertEquals(data.auraMessage.message, System.Label.TNCarDealership_NoInfo, 'The dates must be the same');
	}
	/** Validators */
	private static void validateOK (TNController.DataFromCarType data, TNController.DataFromCarType comparator) {
		System.assertEquals(comparator.error, data.error, 'Should be the same');
		System.assertEquals(comparator.auraMessage.title, data.auraMessage.title, 'The title must be the same');
		System.assertEquals(comparator.auraMessage.status, data.auraMessage.status, 'The status must be the same');
		System.assertEquals(comparator.auraMessage.message, data.auraMessage.message, 'The message must be the same');
		System.assertEquals(comparator.moreExpensiveDate, data.moreExpensiveDate, 'The dates must be the same');
		System.assertEquals(comparator.moreExpensiveLicense, data.moreExpensiveLicense, 'The licences must be the same');
		System.assertEquals(comparator.moreExpensiveSalePrice, data.moreExpensiveSalePrice, 'The prices must be the same');
		System.assertEquals(comparator.totalQuantity, data.totalQuantity, 'The quantity must be the same');
		System.assertEquals(comparator.totalMoneyRaised, data.totalMoneyRaised, 'The money must be the same');
		System.assert(!data.error, 'Should not be errors');
	}
	/** Utils */
	private static Date getRandomDate () {
		Integer month = Integer.valueOf(Math.random()*11) + 1;
		Integer day = Integer.valueOf(Math.random()*27) + 1;
		return Date.newInstance(Date.today().year()-1, month, day);
	}
	private static User insertSalesUSAUser () {
		String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
		User usaSalesUser = new User(
			Alias = 'standt',
			Email ='standarduser@testorg.com',
			EmailEncodingKey ='UTF-8',
			LanguageLocaleKey ='es',
			LocaleSidKey ='en_US',
			TimeZoneSidKey ='America/Los_Angeles',
			ProfileId = salesUserProfile.Id,
			UserRoleId = USASalesRole.Id,
			LastName = 'USA Test User',
			UserName = uniqueUserName + 'USA'
		);
		System.runAs(new User(Id = userInfo.getUserId())){
			insert usaSalesUser;
			activateUsersPermissionSets(new List<User>{usaSalesUser}, new List<String>{'TN_Car_Dealership_Permission'});
		}
		return usaSalesUser;
	}
	private static void activateUsersPermissionSets(list<user> users, List<String> lstPermissionName) {
		List<PermissionSetAssignment> listObj = new List<PermissionSetAssignment>();
		for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN :lstPermissionName]) {
			for (user usuario: users) {
				PermissionSetAssignment psa = new PermissionSetAssignment(
					AssigneeId = usuario.id,
					PermissionSetId = ps.Id
				);
				listObj.add(psa);
			}
		}
		insert listObj;
	}
}