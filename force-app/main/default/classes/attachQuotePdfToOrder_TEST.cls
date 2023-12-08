@IsTest
public class attachQuotePdfToOrder_TEST {
    
    @TestSetup
    static void makeData(){

        // create Test Account
        Account a = new Account();
        a.Name = 'Test Account';
        a.OperatingCompany__c = 'Plantyn';
        a.Area__c = 'Dutch';
        insert a;
        
        // Create Test Order
        Order o = new Order();
        o.AccountId = a.Id;
        o.Status = 'Draft';
        o.EffectiveDate = Date.today().addMonths(-10);
        insert o;
    }

    @IsTest
    static void methodName(){
        
        Order o = [Select Id FROM Order LIMIT 1];
        Pagereference pageRef = page.attachQuoteToOrder;
        pageRef.getParameters().put('Id', o.Id);

        ApexPages.StandardController stc = new ApexPages.StandardController(o);
        attachQuotePdfToOrder aQ = new attachQuotePdfToOrder(stc);

        PageReference objPageRef = aQ.attachPDF();
        
    }
}