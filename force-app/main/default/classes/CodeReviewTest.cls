@isTest
public with sharing class CodeReviewTest {
	private static List<String> bodyStyles = new List<String>{'Sedan', 'Convertible'};
	private static List<String> brands = new List<String>{'Chevrolet', 'Fiat'};
	private static List<String> models = new List<String>{'Blazer', '500L'};
	private static List<String> countries = new List<String>{'Japan', 'Italy', 'USA', 'South Korea', 'England'};
	private static TNController.DataFromCarType comparator1;
	private static TNController.DataFromCarType comparator2;
	private static String carType1Id;
	private static String carType2Id;
	private static String carType3Id;
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
				TNPrice__c = Math.roundToLong(90000*Math.random() + 10000),
				TNDate__c = getRandomDate()
			);
			sales.add(sale);
		}
		insert sales;
		sales = [SELECT TNType__c, TNDate__c, TNPrice__c, TNCarType__c, TNCarLicence__c FROM TNCarSales__c];
		List<TNCarSales__c> toCompare1 = new List<TNCarSales__c>();
		List<TNCarSales__c> toCompare2 = new List<TNCarSales__c>();
		for (TNCarSales__c sale : sales) {
			if (sale.TNCarType__c == '1') {toCompare1.add(sale);}
			else {toCompare2.add(sale);}
		}
		comparator1 = new TNController.DataFromCarType(toCompare1);
		comparator2 = new TNController.DataFromCarType(toCompare2);
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
		System.assert(!data.error, 'Should not be errors');
		System.assertEquals(data.auraMessage.title, 'Success', 'The dates must be the same');
		System.assertEquals(data.auraMessage.status, 'success', 'The dates must be the same');
		System.assertEquals(data.auraMessage.message, 'Ok', 'The dates must be the same');
		System.assertEquals(comparator1.moreExpensiveDate, data.moreExpensiveDate, 'The dates must be the same');
		System.assertEquals(comparator1.moreExpensiveLicense, data.moreExpensiveLicense, 'The licences must be the same');
		System.assertEquals(comparator1.moreExpensiveSalePrice, data.moreExpensiveSalePrice, 'The prices must be the same');
		System.assertEquals(comparator1.totalQuantity, data.totalQuantity, 'The quantity must be the same');
		System.assertEquals(comparator1.totalMoneyRaised, data.totalMoneyRaised, 'The money must be the same');
	}
	@isTest
	private static void returnDataFromType2 () {
		TNController.DataFromCarType data = TNController.getSalesDataFromCarType(carType2Id);
		System.assert(!data.error, 'Should not be errors');
		System.assertEquals(data.auraMessage.title, 'Success', 'The dates must be the same');
		System.assertEquals(data.auraMessage.status, 'success', 'The dates must be the same');
		System.assertEquals(data.auraMessage.message, 'Ok', 'The dates must be the same');
		System.assertEquals(comparator2.moreExpensiveDate, data.moreExpensiveDate, 'The dates must be the same');
		System.assertEquals(comparator2.moreExpensiveLicense, data.moreExpensiveLicense, 'The licences must be the same');
		System.assertEquals(comparator2.moreExpensiveSalePrice, data.moreExpensiveSalePrice, 'The prices must be the same');
		System.assertEquals(comparator2.totalQuantity, data.totalQuantity, 'The quantity must be the same');
		System.assertEquals(comparator2.totalMoneyRaised, data.totalMoneyRaised, 'The money must be the same');
	}
	@isTest
	private static void ifNoDataReturnMessage () {
		TNController.DataFromCarType data = TNController.getSalesDataFromCarType(carType3Id);
		System.assert(data.error, 'Should be errors');
		System.assertEquals(data.auraMessage.title, 'Warning', 'The dates must be the same');
		System.assertEquals(data.auraMessage.status, 'warning', 'The dates must be the same');
		System.assertEquals(data.auraMessage.message, System.Label.TNCarDealership_NoInfo, 'The dates must be the same');
	}
	/** Utils */
	private static Date getRandomDate () {
		Integer month = Integer.valueOf(Math.random()*11) + 1;
		Integer day = Integer.valueOf(Math.random()*27) + 1;
		return Date.newInstance(Date.today().year()-1, month, day);
	}
}