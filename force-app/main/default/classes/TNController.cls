public class TNController {
	@AuraEnabled
	public static DataFromCarType getSalesDataFromCarType(String Id) {
		return new DataFromCarType(new List<TNCarSales__c>());
	}
	public class DataFromCarType {
		@AuraEnabled public List<TNCarSales__c> sales;
		@AuraEnabled public Integer totalQuantity;
		@AuraEnabled public Double totalMoneyRaised;
		@AuraEnabled public Date moreExpensiveDate;
		@AuraEnabled public String moreExpensiveLicense;
		@AuraEnabled public Double moreExpensiveSalePrice;
		public DataFromCarType(List<TNCarSales__c> sales) {
			this.sales = sales;
			this.totalQuantity = 0;
			this.totalMoneyRaised = 0;
			for (TNCarSales__c sale : sales) {
				this.totalQuantity += 1;
				this.totalMoneyRaised += sale.TNPrice__c;
				if (this.moreExpensiveSalePrice < sale.TNPrice__c) {
					this.moreExpensiveSalePrice = sale.TNPrice__c;
					this.moreExpensiveLicense = sale.TNCarLicence__c;
					this.moreExpensiveDate = sale.TNDate__c;
				}
			}
		}
	}
}