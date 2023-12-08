@Istest
public with sharing class Order_OrderActivateQueueHandler_test {
    

static testmethod void BatchOrderActivateAssetRenew1(){    
    Test.startTest();
        
    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    Set<String> Set_AccId = new Set<String>();
    for(Account acc:lstAccount){
        Set_AccId.add(acc.id);
    }

    AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

    Map<String,String> Map_AccSub = new Map<String,String>();
    Integer i=0;
    for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
        sub.NetsuiteInternalId__c = '88776'+i;
        Map_AccSub.put(sub.Account__c,sub.id);
        i++;
    }

    update lstAccountSubsidiary;

    List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
    Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
    List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
    List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
    List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
    
    for(Order ord:lstOrder){
        ord.ActivateforBatchProcessing__c =true;
        ord.NetSuiteIdShiptoAccount__c = '887760';
        ord.NetSuiteIdAccountSubsidiary__c = Map_AccSub.get(ord.Billto__c); 
        ord.AccountSubsidiary__c = Map_AccSub.get(ord.Billto__c);
    }
    
    Insert lstOrder;

    List<OrderItem> lstOrderItems = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false); 

    
    List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
    
    Date CurrrentDay = system.today();
    
    Map<String,String> Map_Asset = new Map<String,String>();

    for(Asset ass:lst_Asset){
        ass.LastRenewalUpdate__c =CurrrentDay;
    }
    Insert lst_Asset;

    for(Asset ass:lst_Asset){
        Map_Asset.put(ass.Product2Id,ass.id);
    }


    system.debug('***BatchOrderActivate: Map_Asset'+Map_Asset);

    for(OrderItem item:lstOrderItems){
        item.Asset__c = Map_Asset.get(item.Product2Id);

        system.debug('***BatchOrderActivate: Map_Asset: Ind'+Map_Asset.get(item.Product2Id));

    }
    insert lstOrderItems;

    lstOrder[0].ActivateforBatchProcessing__c =true;
    lstOrder[0].TriggerBusinessRules__c =true;
    update lstOrder;
    
    String checked = '';
    Set<String> Set_Checked = new Set<String>();

    Order[] nextOrder = [SELECT LineCount__c,ActivateforBatchProcessing__c,ValidateAccountErrors__c,ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateEmailsRequired__c,ValidateActivateShippingAddressRequired__c,ValidateActivateValidation__c,ValidateB2BLineCountError__c,ValidateBilltoErrors__c,ValidateBillingAddress__c,ValidateBillToEmpty__c,ValidateCreditLimitCheck__c,ValidateFreeAndServiceMustbeZeroOnActiv__c,ValidateInventoryOnMultipleLocations__c,ValidateNetSalesPrice__c,ValidateOrderAmount__c,ValidateReferenceNumberCheck__c,ValidateShiptoErrors__c,ValidateShippingCostExclVAT__c,ValidateShippingAddress__c,ValidateShipToEmpty__c,ValidateTotalLineItemQuantities__c,ValidateDigitalforNetherlands__c,ValidateStartEndDateonOnItems__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c
    FROM Order ];
    
    
    system.debug('***ValidateAccountErrors__c**'+nextOrder[0].ValidateAccountErrors__c);
    system.debug('***ValidateActivateAccountSubsidiaryRequir__c**'+nextOrder[0].ValidateActivateAccountSubsidiaryRequir__c);
    system.debug('***ValidateActivateEmailsRequired__c**'+nextOrder[0].ValidateActivateEmailsRequired__c);
    system.debug('***ValidateActivateShippingAddressRequired__c**'+nextOrder[0].ValidateActivateShippingAddressRequired__c);
    system.debug('***ValidateActivateValidation__c**'+nextOrder[0].ValidateActivateValidation__c);
    system.debug('***ValidateB2BLineCountError__c**'+nextOrder[0].ValidateB2BLineCountError__c);
    system.debug('***ValidateBilltoErrors__c**'+nextOrder[0].ValidateBilltoErrors__c);
    system.debug('***ValidateBillingAddress__c**'+nextOrder[0].ValidateBillingAddress__c);
    system.debug('***ValidateBillToEmpty__c**'+nextOrder[0].ValidateBillToEmpty__c);
    system.debug('***ValidateCreditLimitCheck__c**'+nextOrder[0].ValidateCreditLimitCheck__c);
    system.debug('***ValidateFreeAndServiceMustbeZeroOnActiv__c**'+nextOrder[0].ValidateFreeAndServiceMustbeZeroOnActiv__c);
    system.debug('***ValidateInventoryOnMultipleLocations__c**'+nextOrder[0].ValidateInventoryOnMultipleLocations__c);
    system.debug('***ValidateNetSalesPrice__c**'+nextOrder[0].ValidateNetSalesPrice__c);
    system.debug('***ValidateOrderAmount__c**'+nextOrder[0].ValidateOrderAmount__c);
    system.debug('***ValidateReferenceNumberCheck__c**'+nextOrder[0].ValidateReferenceNumberCheck__c);
    system.debug('***ValidateShiptoErrors__c**'+nextOrder[0].ValidateShiptoErrors__c);
    system.debug('***ValidateShippingCostExclVAT__c**'+nextOrder[0].ValidateShippingCostExclVAT__c);
    system.debug('***ValidateShippingAddress__c**'+nextOrder[0].ValidateShippingAddress__c);
    system.debug('***ValidateShipToEmpty__c**'+nextOrder[0].ValidateShipToEmpty__c);
    system.debug('***ValidateTotalLineItemQuantities__c**'+nextOrder[0].ValidateTotalLineItemQuantities__c);
    system.debug('***ValidateDigitalforNetherlands__c**'+nextOrder[0].ValidateDigitalforNetherlands__c);
    system.debug('***ValidateStartEndDateonOnItems__c**'+nextOrder[0].ValidateStartEndDateonOnItems__c);
    system.debug('***ValidationErrorsOrder__c**'+nextOrder[0].ValidationErrorsOrder__c);
    system.debug('***ValidationErrorsOrderProducts__c**'+nextOrder[0].ValidationErrorsOrderProducts__c);
    

    lstOrderItems = [Select ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateDigitalActivationEmail__c,ValidateActivateNetSuiteId__c,ValidateActivateShippingAddressRequired__c,ValidateActiveandNoAsset__c,ValidateAll__c,ValidateCalculatedVAT__c,ValidateCannotSellLicenseMoreThan12Mont__c,ValidateDigitalActivationEmail__c,ValidateLineItemTotal__c,ValidateNegativeDiscount__c,ValidateNetSalesPrice__c,ValidateNetSalesPriceAgainstDiscount__c,ValidateNetSalesPriceCantbeNegative__c,ValidateNetsuiteQuantityMustbegreaterth__c,ValidateOrderLineTypeCheck__c,ValidateProductComponentNonRenewable__c,ValidateProductMaxQuantity__c,ValidateReferenceNumberCheck__c,ValidateDigitalforNetherlands__c,validateVATNetherlandsDigital__c 
    from Orderitem ];
  
system.debug('***Validate LineCount__c**'+nextOrder[0].LineCount__c);
    system.debug('***Validate ActivateforBatchProcessing**'+nextOrder[0].ActivateforBatchProcessing__c);

    for(Orderitem item:lstOrderItems){
        system.debug('***Validate ActivateAccountSubsidiaryRequir**'+item.ValidateActivateAccountSubsidiaryRequir__c);
system.debug('***Validate ActivateDigitalActivationEmail**'+item.ValidateActivateDigitalActivationEmail__c);
system.debug('***Validate ActivateNetSuiteId**'+item.ValidateActivateNetSuiteId__c);
system.debug('***Validate ActivateShippingAddressRequired**'+item.ValidateActivateShippingAddressRequired__c);
system.debug('***Validate Active and No Asset**'+item.ValidateActiveandNoAsset__c);
system.debug('***Validate All**'+item.ValidateAll__c);
system.debug('***Validate Calculated VAT**'+item.ValidateCalculatedVAT__c);
system.debug('***Validate CannotSellLicenseMoreThan12Mont**'+item.ValidateCannotSellLicenseMoreThan12Mont__c);
system.debug('***Validate DigitalActivationEmail**'+item.ValidateDigitalActivationEmail__c);
system.debug('***Validate Line Item Total**'+item.ValidateLineItemTotal__c);
system.debug('***Validate NegativeDiscount**'+item.ValidateNegativeDiscount__c);
system.debug('***Validate NetSalesPrice**'+item.ValidateNetSalesPrice__c);
system.debug('***Validate NetSalesPriceAgainstDiscount**'+item.ValidateNetSalesPriceAgainstDiscount__c);
system.debug('***Validate NetSalesPriceCantbeNegative**'+item.ValidateNetSalesPriceCantbeNegative__c);
system.debug('***Validate NetsuiteQuantityMustbegreaterth**'+item.ValidateNetsuiteQuantityMustbegreaterth__c);
system.debug('***Validate OrderLineTypeCheck**'+item.ValidateOrderLineTypeCheck__c);
system.debug('***Validate ProductComponentNonRenewable**'+item.ValidateProductComponentNonRenewable__c);
system.debug('***Validate ProductMaxQuantity**'+item.ValidateProductMaxQuantity__c);
system.debug('***Validate ReferenceNumberCheck**'+item.ValidateReferenceNumberCheck__c);
system.debug('***ValidateDigitalforNetherlands**'+item.ValidateDigitalforNetherlands__c);
system.debug('***validateVATNetherlandsDigital**'+item.validateVATNetherlandsDigital__c);

    }
  
    Order_OrderActivateQueueHandler.checknextOrder(checked,Set_Checked);

    Test.stopTest();
        
}

static testmethod void BatchOrderActivateAssetRenew2(){    
    Test.startTest();
        
    List<Account> lstAccount = TestDataFactory.insertAccountsSubsidiary(2, 'Plantyn',true,true);

    Set<String> Set_AccId = new Set<String>();
    for(Account acc:lstAccount){
        Set_AccId.add(acc.id);
    }

    AccountSubsidiary__c[] lstAccountSubsidiary = [Select id,Account__c from AccountSubsidiary__c where Account__c in:Set_AccId ];

    Map<String,String> Map_AccSub = new Map<String,String>();
    Integer i=0;
    for(AccountSubsidiary__c  sub:lstAccountSubsidiary){
        sub.NetsuiteInternalId__c = '88776'+i;
        Map_AccSub.put(sub.Account__c,sub.id);
        i++;
    }

    update lstAccountSubsidiary;

    List<Product2> lstProduct = TestDataFactory.insertProducts(1,true);
    Pricebook2 standardPricebook = TestDataFactory.insertPricebook();
    List<PricebookEntry> lstPricebookEntry = TestDataFactory.insertPricebookEntry(standardPricebook.id ,lstProduct,true);
    List<Contract> lstContract = TestDataFactory.insertContract(1,lstAccount,standardPricebook.id,true);
    List<Order> lstOrder = TestDataFactory.insertOrderHeader(1,lstAccount,lstContract,standardPricebook.id,false);
    
    for(Order ord:lstOrder){
        ord.ActivateforBatchProcessing__c =true;
        ord.NetSuiteIdShiptoAccount__c = '887760';
        ord.NetSuiteIdAccountSubsidiary__c = Map_AccSub.get(ord.Billto__c); 
        ord.AccountSubsidiary__c = Map_AccSub.get(ord.Billto__c);
    }
    
    Insert lstOrder;

    List<OrderItem> lstOrderItems; // = TestDataFactory.insertOrderItems(1,lstAccount,Map_AccSub,lstOrder,lstPricebookEntry,false); 

    
    List<Asset>lst_Asset = TestDataFactory.insertAsset(standardPricebook.id ,lstProduct,lstAccount, lstAccount,false);
    
    Date CurrrentDay = system.today();
    
    Map<String,String> Map_Asset = new Map<String,String>();

    for(Asset ass:lst_Asset){
        ass.LastRenewalUpdate__c =CurrrentDay;
    }
    Insert lst_Asset;

    for(Asset ass:lst_Asset){
        Map_Asset.put(ass.Product2Id,ass.id);
    }


    system.debug('***BatchOrderActivate: Map_Asset'+Map_Asset);
/*
    for(OrderItem item:lstOrderItems){
        item.Asset__c = Map_Asset.get(item.Product2Id);

        system.debug('***BatchOrderActivate: Map_Asset: Ind'+Map_Asset.get(item.Product2Id));

    }
    insert lstOrderItems;
*/
    lstOrder[0].ActivateforBatchProcessing__c =true;
    lstOrder[0].TriggerBusinessRules__c =true;
    update lstOrder;
    
    String checked = null;
    Set<String> Set_Checked = new Set<String>();

    Order[] nextOrder = [SELECT LineCount__c,ActivateforBatchProcessing__c,ValidateAccountErrors__c,ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateEmailsRequired__c,ValidateActivateShippingAddressRequired__c,ValidateActivateValidation__c,ValidateB2BLineCountError__c,ValidateBilltoErrors__c,ValidateBillingAddress__c,ValidateBillToEmpty__c,ValidateCreditLimitCheck__c,ValidateFreeAndServiceMustbeZeroOnActiv__c,ValidateInventoryOnMultipleLocations__c,ValidateNetSalesPrice__c,ValidateOrderAmount__c,ValidateReferenceNumberCheck__c,ValidateShiptoErrors__c,ValidateShippingCostExclVAT__c,ValidateShippingAddress__c,ValidateShipToEmpty__c,ValidateTotalLineItemQuantities__c,ValidateDigitalforNetherlands__c,ValidateStartEndDateonOnItems__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c
    FROM Order ];
 

  
    System.enqueueJob(new Order_OrderActivateQueueHandler(null,checked,'Start',Set_Checked));

    Test.stopTest();
        
}
/*
    Order[] nextOrder = [SELECT LineCount__c,ActivateforBatchProcessing__c,ValidateAccountErrors__c,ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateEmailsRequired__c,ValidateActivateShippingAddressRequired__c,ValidateActivateValidation__c,ValidateB2BLineCountError__c,ValidateBilltoErrors__c,ValidateBillingAddress__c,ValidateBillToEmpty__c,ValidateCreditLimitCheck__c,ValidateFreeAndServiceMustbeZeroOnActiv__c,ValidateInventoryOnMultipleLocations__c,ValidateNetSalesPrice__c,ValidateOrderAmount__c,ValidateReferenceNumberCheck__c,ValidateShiptoErrors__c,ValidateShippingCostExclVAT__c,ValidateShippingAddress__c,ValidateShipToEmpty__c,ValidateTotalLineItemQuantities__c,ValidateDigitalforNetherlands__c,ValidateStartEndDateonOnItems__c,ValidationErrorsOrder__c,ValidationErrorsOrderProducts__c
    FROM Order ];
    
    
    system.debug('***ValidateAccountErrors__c**'+nextOrder[0].ValidateAccountErrors__c);
    system.debug('***ValidateActivateAccountSubsidiaryRequir__c**'+nextOrder[0].ValidateActivateAccountSubsidiaryRequir__c);
    system.debug('***ValidateActivateEmailsRequired__c**'+nextOrder[0].ValidateActivateEmailsRequired__c);
    system.debug('***ValidateActivateShippingAddressRequired__c**'+nextOrder[0].ValidateActivateShippingAddressRequired__c);
    system.debug('***ValidateActivateValidation__c**'+nextOrder[0].ValidateActivateValidation__c);
    system.debug('***ValidateB2BLineCountError__c**'+nextOrder[0].ValidateB2BLineCountError__c);
    system.debug('***ValidateBilltoErrors__c**'+nextOrder[0].ValidateBilltoErrors__c);
    system.debug('***ValidateBillingAddress__c**'+nextOrder[0].ValidateBillingAddress__c);
    system.debug('***ValidateBillToEmpty__c**'+nextOrder[0].ValidateBillToEmpty__c);
    system.debug('***ValidateCreditLimitCheck__c**'+nextOrder[0].ValidateCreditLimitCheck__c);
    system.debug('***ValidateFreeAndServiceMustbeZeroOnActiv__c**'+nextOrder[0].ValidateFreeAndServiceMustbeZeroOnActiv__c);
    system.debug('***ValidateInventoryOnMultipleLocations__c**'+nextOrder[0].ValidateInventoryOnMultipleLocations__c);
    system.debug('***ValidateNetSalesPrice__c**'+nextOrder[0].ValidateNetSalesPrice__c);
    system.debug('***ValidateOrderAmount__c**'+nextOrder[0].ValidateOrderAmount__c);
    system.debug('***ValidateReferenceNumberCheck__c**'+nextOrder[0].ValidateReferenceNumberCheck__c);
    system.debug('***ValidateShiptoErrors__c**'+nextOrder[0].ValidateShiptoErrors__c);
    system.debug('***ValidateShippingCostExclVAT__c**'+nextOrder[0].ValidateShippingCostExclVAT__c);
    system.debug('***ValidateShippingAddress__c**'+nextOrder[0].ValidateShippingAddress__c);
    system.debug('***ValidateShipToEmpty__c**'+nextOrder[0].ValidateShipToEmpty__c);
    system.debug('***ValidateTotalLineItemQuantities__c**'+nextOrder[0].ValidateTotalLineItemQuantities__c);
    system.debug('***ValidateDigitalforNetherlands__c**'+nextOrder[0].ValidateDigitalforNetherlands__c);
    system.debug('***ValidateStartEndDateonOnItems__c**'+nextOrder[0].ValidateStartEndDateonOnItems__c);
    system.debug('***ValidationErrorsOrder__c**'+nextOrder[0].ValidationErrorsOrder__c);
    system.debug('***ValidationErrorsOrderProducts__c**'+nextOrder[0].ValidationErrorsOrderProducts__c);
    

    lstOrderItems = [Select ValidateActivateAccountSubsidiaryRequir__c,ValidateActivateDigitalActivationEmail__c,ValidateActivateNetSuiteId__c,ValidateActivateShippingAddressRequired__c,ValidateActiveandNoAsset__c,ValidateAll__c,ValidateCalculatedVAT__c,ValidateCannotSellLicenseMoreThan12Mont__c,ValidateDigitalActivationEmail__c,ValidateLineItemTotal__c,ValidateNegativeDiscount__c,ValidateNetSalesPrice__c,ValidateNetSalesPriceAgainstDiscount__c,ValidateNetSalesPriceCantbeNegative__c,ValidateNetsuiteQuantityMustbegreaterth__c,ValidateOrderLineTypeCheck__c,ValidateProductComponentNonRenewable__c,ValidateProductMaxQuantity__c,ValidateReferenceNumberCheck__c,ValidateDigitalforNetherlands__c,validateVATNetherlandsDigital__c 
    from Orderitem ];
  
system.debug('***Validate LineCount__c**'+nextOrder[0].LineCount__c);
    system.debug('***Validate ActivateforBatchProcessing**'+nextOrder[0].ActivateforBatchProcessing__c);

    for(Orderitem item:lstOrderItems){
        system.debug('***Validate ActivateAccountSubsidiaryRequir**'+item.ValidateActivateAccountSubsidiaryRequir__c);
system.debug('***Validate ActivateDigitalActivationEmail**'+item.ValidateActivateDigitalActivationEmail__c);
system.debug('***Validate ActivateNetSuiteId**'+item.ValidateActivateNetSuiteId__c);
system.debug('***Validate ActivateShippingAddressRequired**'+item.ValidateActivateShippingAddressRequired__c);
system.debug('***Validate Active and No Asset**'+item.ValidateActiveandNoAsset__c);
system.debug('***Validate All**'+item.ValidateAll__c);
system.debug('***Validate Calculated VAT**'+item.ValidateCalculatedVAT__c);
system.debug('***Validate CannotSellLicenseMoreThan12Mont**'+item.ValidateCannotSellLicenseMoreThan12Mont__c);
system.debug('***Validate DigitalActivationEmail**'+item.ValidateDigitalActivationEmail__c);
system.debug('***Validate Line Item Total**'+item.ValidateLineItemTotal__c);
system.debug('***Validate NegativeDiscount**'+item.ValidateNegativeDiscount__c);
system.debug('***Validate NetSalesPrice**'+item.ValidateNetSalesPrice__c);
system.debug('***Validate NetSalesPriceAgainstDiscount**'+item.ValidateNetSalesPriceAgainstDiscount__c);
system.debug('***Validate NetSalesPriceCantbeNegative**'+item.ValidateNetSalesPriceCantbeNegative__c);
system.debug('***Validate NetsuiteQuantityMustbegreaterth**'+item.ValidateNetsuiteQuantityMustbegreaterth__c);
system.debug('***Validate OrderLineTypeCheck**'+item.ValidateOrderLineTypeCheck__c);
system.debug('***Validate ProductComponentNonRenewable**'+item.ValidateProductComponentNonRenewable__c);
system.debug('***Validate ProductMaxQuantity**'+item.ValidateProductMaxQuantity__c);
system.debug('***Validate ReferenceNumberCheck**'+item.ValidateReferenceNumberCheck__c);
system.debug('***ValidateDigitalforNetherlands**'+item.ValidateDigitalforNetherlands__c);
system.debug('***validateVATNetherlandsDigital**'+item.validateVATNetherlandsDigital__c);

    }
*/    
}