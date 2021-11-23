public class TNController {
	@AuraEnabled
	public static List<TNCarType__c> getCarTypes(){
		List<TNCarType__c> listToReturn;
		try {
			listToReturn = [SELECT TNBodyStyle__c, TNCarBrand__c, TNModel__c FROM TNCarType__c WITH SECURITY_ENFORCED];
			return listToReturn;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
	@AuraEnabled
	public static DataFromCarType getSalesDataFromCarType(String Id) {
		List<TNCarSales__c> sales = [SELECT TNPrice__c, TNDate__c, TNCarLicence__c FROM TNCarSales__c WHERE TNCar__r.TNCarType__c =: Id WITH SECURITY_ENFORCED];
		return new DataFromCarType(sales);
	}
	public class DataFromCarType {
		@AuraEnabled public AuraMessage auraMessage {get; set;}
		@AuraEnabled public Boolean error {get; set;}
		@AuraEnabled public List<TNCarSales__c> sales {get; set;}
		@AuraEnabled public Integer totalQuantity {get; set;}
		@AuraEnabled public Double totalMoneyRaised {get; set;}
		@AuraEnabled public Date moreExpensiveDate {get; set;}
		@AuraEnabled public String moreExpensiveLicense {get; set;}
		@AuraEnabled public Double moreExpensiveSalePrice {get; set;}
		public DataFromCarType(List<TNCarSales__c> sales) {
			this.auraMessage = new AuraMessage();
			if (sales.isEmpty()) {
				this.error = true;
				this.auraMessage.title = 'Warning';
				this.auraMessage.status = 'warning';
				this.auraMessage.message = System.Label.TNCarDealership_NoInfo;
			}
			else {
				this.sales = sales;
				this.totalQuantity = 0;
				this.totalMoneyRaised = 0;
				this.moreExpensiveSalePrice = 0;
				for (TNCarSales__c sale : sales) {
					this.totalQuantity += 1;
					this.totalMoneyRaised += sale.TNPrice__c;
					if (this.moreExpensiveSalePrice < sale.TNPrice__c) {
						this.moreExpensiveSalePrice = sale.TNPrice__c;
						this.moreExpensiveLicense = sale.TNCarLicence__c;
						this.moreExpensiveDate = sale.TNDate__c;
					}
				}
				this.error = false;
				this.auraMessage.title = 'Success';
				this.auraMessage.status = 'success';
				this.auraMessage.message = 'Ok';
			}
		}
	}
	public class AuraMessage {
		@AuraEnabled public String title {get; set;}
		@AuraEnabled public String status {get; set;}
		@AuraEnabled public String message {get; set;}
	}
}