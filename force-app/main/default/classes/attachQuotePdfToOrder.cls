public with sharing class attachQuotePdfToOrder {
    
    private final Order order;

    public attachQuotePdfToOrder(ApexPages.StandardController standardPageController) {
        order = (Order)standardPageController.getRecord();
        System.debug('attachQuotePdfToOrder - orderId = ' + order.Id);
    }

    public PageReference attachPDF() {

        Order order = [SELECT OrderNumber, QuoteVersion__c FROM Order WHERE Id = :order.Id LIMIT 1];

        Integer version = 1;

        if (order.QuoteVersion__c == null || order.QuoteVersion__c == 0) {
            order.QuoteVersion__c = 1;
        } else {
            version = Integer.valueOf(order.QuoteVersion__c);
            order.QuoteVersion__c += 1;
        }
        order.Status = 'Under Review';
        update order;

        PageReference pageRef =  Page.orderToPdf;
        pageRef.getParameters().put('Id',order.Id);
        Blob ret;
        if (!test.isRunningTest()) {
            ret = pageRef.getContentAsPDF();
        } else {
            ret = blob.valueOf('Test');
        }
        String base64 = EncodingUtil.base64Encode(ret);
        String  respuesta='';

        ContentVersion v = new ContentVersion();
        v.versionData = EncodingUtil.base64Decode(base64);
        v.title = 'Quote_' + order.OrderNumber + '-v' + version + '_' + Date.today().format() + '.pdf';
        v.pathOnClient = 'Quote_' + order.OrderNumber + '.pdf';
        insert v;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:v.Id].ContentDocumentId;
        ContentDocumentLink cDe = new ContentDocumentLink();
        cDe.ContentDocumentId = conDoc;
        cDe.LinkedEntityId = Order.Id;
        cDe.ShareType = 'I';
        cDe.Visibility = 'AllUsers';
        insert cDe;  

        ContentVersion cv = [select id from contentversion where contentdocumentid =:conDoc];
        respuesta =cv.id;
        ContentDistribution cd = new ContentDistribution();
        cd.Name = 'IRNPDF';
        cd.ContentVersionId =  cv.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;

        insert cd;

        Pagereference backToOrder = new ApexPages.StandardController(order).view();
        backToOrder.setRedirect(true);
        return backToOrder;

    }

}