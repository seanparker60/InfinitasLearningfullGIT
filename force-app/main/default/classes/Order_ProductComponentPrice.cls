public class Order_ProductComponentPrice {
    
    
    
    public static void removedeleteProductPrice(Map<id,Pricing__c> Map_PriceInit){
       
            Pricing__c[] lstPriceInit = [Select ProductComponent__r.MainProduct__c from Pricing__c where id in: Map_PriceInit.keyset() ];

            system.debug('**Order_ProductComponentPrice: removedeleteProductPrice**'+Map_PriceInit);
            system.debug('**Order_ProductComponentPrice: removedeleteProductPrice:lstPriceInit**'+lstPriceInit);
           
            Set<String> SetMainProduct = new Set<String>();
            Set<String> SetProduct = new Set<String>();
            List<Id> lstdeleted = new List<Id>();
            for(Pricing__c  p:lstPriceInit){
                SetMainProduct.add(p.ProductComponent__r.MainProduct__c);
                SetProduct.add(p.ProductComponent__c);
                lstdeleted.add(p.id);

                system.debug('**Order_ProductComponentPrice: removedeleteProductPrice**'+p.ProductComponent__r.MainProduct__c);
                system.debug('**Order_ProductComponentPrice: removedeleteProductPrice**'+SetProduct);
            }
            
            Pricing__c[] lstPriceFull = [Select id from Pricing__c where ProductComponent__r.MainProduct__c  in:SetMainProduct AND ProductComponent__c not in: SetProduct ];
            
            List<Id> PriceId = new List<Id>();

            for(Pricing__c  p:lstPriceFull){
                PriceId.add(p.id);
            }
           // system.debug('**Order_ProductComponentPrice: removedeleteProductPrice**'+PriceId);
            MainProductPriceCount(PriceId,lstdeleted);
       

    }    

    @invocablemethod
    public static void updateMainProductPriceCount(List<Id> PriceId){
        
        List<Id> lstdeleted = new List<Id>();
        MainProductPriceCount(PriceId,lstdeleted);

    }    


    public static void MainProductPriceCount(List<Id> PriceId,List<Id> lstdeleted){    

        Pricing__c[] lstPriceInit = [Select ProductComponent__r.MainProduct__c from Pricing__c where id in: PriceId ];


        Set<String> SetMainProduct = new Set<String>();

        Set<String> SetProduct = new Set<String>();

        for(Pricing__c  p:lstPriceInit){
            SetMainProduct.add(p.ProductComponent__r.MainProduct__c);
        }

        Pricing__c[] lstPriceFull = [Select ProductComponent__r.MainProduct__c from Pricing__c where 
                ProductComponent__r.MainProduct__c  in:SetMainProduct 
                AND ProductComponent__r.MainProduct__c !=: null 
                AND  id not in: lstdeleted];
        
        for(Pricing__c  p:lstPriceFull){
            SetProduct.add(p.ProductComponent__c);
        }
        
        system.debug('**Order_ProductComponentPrice: SetProduct**'+SetProduct);

        ProductComponent__c[] lstProductComponent = [Select id,MainProduct__c,MissingComponentPrice__c from ProductComponent__c where MainProduct__c in: SetMainProduct AND MainProduct__c !=: null];

        Map<String,Decimal> Map_MainProd = new Map<String,Decimal>(); 


        system.debug('**Order_ProductComponentPrice: lstProductComponent**'+lstProductComponent);

        for(ProductComponent__c comp:lstProductComponent){
            if(!SetProduct.contains(comp.id)){
                if(Map_MainProd.get(comp.MainProduct__c) == null){
                    Map_MainProd.put(comp.MainProduct__c,1);
                }	
                else {
                    Map_MainProd.put(comp.MainProduct__c,Map_MainProd.get(comp.MainProduct__c)+1);
                }	
                comp.MissingComponentPrice__c = true;
            }
            else{
                comp.MissingComponentPrice__c = false;
            }
            
        }

        Product2[] lstMainProduct = [Select id,MissingComponentPriceCount__c,itemGroupManualBlock__c  from Product2 where id in:SetMainProduct ];


        for(Product2 p:lstMainProduct){

                if(Map_MainProd.get(p.id) != null){
                    p.MissingComponentPriceCount__c = Map_MainProd.get(p.id);
                    p.itemGroupManualBlock__c = true;
                }
                else{
                    p.MissingComponentPriceCount__c = 0;
                    p.itemGroupManualBlock__c = false; 
                }

        }

        try{
            update lstMainProduct;
            update lstProductComponent;
        }
        catch(Exception e){
            system.debug('**Order_ProductComponentPrice: error**'+e.getMessage());
            HandleCustomException.LogException(e,lstMainProduct[0].id); 
        }
    
    }    



}