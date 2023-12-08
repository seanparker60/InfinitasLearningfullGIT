public with sharing class Order_UpdateShippingCostsFromItems {
    

    Public static Order UpdateShippingCostsFromItems (List<OrderItem> lstOrderItem, Order CurOrder){    
    
        
        Decimal NonDomesticWeight=null;
        Decimal DomesticWeight=null;
        Decimal OrderBasedTotal=null;
    
        Set<String> Set_ItemId = new Set<String>();
        for(OrderItem item:lstOrderItem){
            Set_ItemId.add(item.id);
    
            //Set_ShippingCountry.add(item.ShippingCountry__c);
            //Set_VAT.add(item.ProductVAT__c);
        }
    
        /*OrderLineItemType__c,*/
    
        //Add query Order include Order fields in class
    
        OrderItem[] lst_OrderItemSelected = [Select Product2.VAT__c,DigitalActivationEMail__c,ShipToAccount__r.DigitalActivationEmail__c, OrderLineType__c,
        ShippingCity__c,ShipToAccount__r.ShippingCity,ShippingCountry__c,ShipToAccount__r.ShippingCountry,ShippingPostalCode__c,ShipToAccount__r.ShippingPostalCode,
        ShippingState__c,ShipToAccount__r.ShippingState,ShippingStreet__c,ShipToAccount__r.ShippingStreet,ShippingIndicationRule__c,Weight__c,Quantity, LineItemTotal__c
        from OrderItem where id in:Set_ItemId]; 
    
        for(OrderItem item: lst_OrderItemSelected){  
            
            system.debug('**UpdateShippingCosts: Order Item Rule **'+ item.ShippingIndicationRule__c);
            system.debug('**UpdateShippingCosts: Weight **'+ item.Weight__c);
            system.debug('**UpdateShippingCosts: Quantity **'+ item.Quantity);
            system.debug('**UpdateShippingCosts: LineItemTotal__c **'+ item.LineItemTotal__c);
            
                 
            if( item.ShippingIndicationRule__c == 'Based on weight Domestic'  && item.Weight__c != null && item.Weight__c > 0){
                if(DomesticWeight != null){
                    DomesticWeight += item.Weight__c; // * item.Quantity;
                } else {
                    DomesticWeight = item.Weight__c; // * item.Quantity;
                }
                
            }
            else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic' && item.Weight__c != null && item.Weight__c > 0 ){
                if(NonDomesticWeight != null){
                    NonDomesticWeight += item.Weight__c; // * item.Quantity;
                } else {
                    NonDomesticWeight = item.Weight__c; // * item.Quantity;
                }
            }
            else if(item.ShippingIndicationRule__c =='Based on order total' && item.LineItemTotal__c != null && item.LineItemTotal__c >= 0 ){    
                if(OrderBasedTotal != null){
                    OrderBasedTotal += item.LineItemTotal__c;
                }
                else{
                    OrderBasedTotal = item.LineItemTotal__c; 
                }
                
            }
            else if(item.ShippingIndicationRule__c =='Shipping Cost Exempt'){
    
            }    
                
        }
    
        //system.debug('**DomesticWeight**'+ DomesticWeight);
        //system.debug('**NonDomesticWeight**'+ NonDomesticWeight);
        system.debug('**UpdateShippingCosts: CurOrder.Billto**'+ CurOrder.Billto__r.OperatingCompany__c);
        system.debug('**UpdateShippingCosts: NonDomesticWeight **'+NonDomesticWeight);
        system.debug('**UpdateShippingCosts: DomesticWeight**'+DomesticWeight);
        system.debug('**UpdateShippingCosts: OrderBasedTotal**'+OrderBasedTotal);
        
    
    
        ShippingCost__c[] lstSCNonDomesticWeight;
        if(NonDomesticWeight != null){
            lstSCNonDomesticWeight = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
            ((StartRangeValue__c <=: NonDomesticWeight AND RangeValue__c >: NonDomesticWeight)  OR (StartRangeValue__c <=: NonDomesticWeight AND RangeValue__c =:null ))
          AND   Subsidiary__c =: CurOrder.Billto__r.OperatingCompany__c
          AND  ShippingRule__c like: '%Based on weight non Domestic%'
          AND  IsActive__c =: true
            ORDER BY RangeValue__c DESC limit 1];
        } 
    
        system.debug('lstSCNonDomesticWeight: ' + lstSCNonDomesticWeight);
    
    
        ShippingCost__c[] lstSCDomesticWeight;
        if(DomesticWeight != null){
            lstSCDomesticWeight = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
            ((StartRangeValue__c <=: DomesticWeight AND RangeValue__c >: DomesticWeight) OR (StartRangeValue__c <=: DomesticWeight AND RangeValue__c =:null ))
                AND Subsidiary__c =: CurOrder.Billto__r.OperatingCompany__c
                AND ShippingRule__c like: '%Based on weight Domestic%'
                AND IsActive__c =: true
                ORDER BY RangeValue__c DESC limit 1];
        } 
    
        system.debug('lstSCDomesticWeight: ' + lstSCDomesticWeight);
    
        ShippingCost__c[] lstSCOrdertotalCost;
        if(OrderBasedTotal != null){
                lstSCOrdertotalCost = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
                ((StartRangeValue__c <=: OrderBasedTotal AND RangeValue__c >: OrderBasedTotal) OR (StartRangeValue__c <=: OrderBasedTotal AND RangeValue__c =:null ))
                AND Subsidiary__c =: CurOrder.Billto__r.OperatingCompany__c
                AND ShippingRule__c like: '%Order Total%'
                AND IsActive__c =: true
                ORDER BY RangeValue__c DESC limit 1];
        }    
        
            //system.debug('lstSCOrdertotalCost.size(): ' + lstSCOrdertotalCost.size());
            system.debug('lstSCOrdertotalCost: ' + lstSCOrdertotalCost);
    
            /*
            system.debug('**lstSCNonDomesticWeight**'+ lstSCNonDomesticWeight[0].Charge__c);
            system.debug('**lstSCDomesticWeight**'+ lstSCDomesticWeight[0].Charge__c);
            */
            CurOrder.ShippingCost__c =null;
            CurOrder.ShippingCostDomestic__c = null;
            CurOrder.ShippingCostNonDomestic__c = null; 
    
            if(lstSCNonDomesticWeight != null && lstSCNonDomesticWeight.size() > 0 && lstSCDomesticWeight != null && lstSCDomesticWeight.size() > 0 && lstSCOrdertotalCost != null && lstSCOrdertotalCost.size()>0){
                CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c += lstSCDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c += lstSCOrdertotalCost[0].Charge__c;
                CurOrder.ShippingCostDomestic__c = lstSCDomesticWeight[0].Charge__c;
                CurOrder.ShippingCostNonDomestic__c = lstSCNonDomesticWeight[0].Charge__c; 
            }
            else if(lstSCNonDomesticWeight != null && lstSCNonDomesticWeight.size() > 0 && lstSCDomesticWeight != null &&  lstSCDomesticWeight.size() > 0){
                CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c += lstSCDomesticWeight[0].Charge__c;
                CurOrder.ShippingCostDomestic__c = lstSCDomesticWeight[0].Charge__c;
                CurOrder.ShippingCostNonDomestic__c = lstSCNonDomesticWeight[0].Charge__c; 
                
            }
            else if(lstSCNonDomesticWeight != null && lstSCNonDomesticWeight.size() > 0 && lstSCOrdertotalCost != null && lstSCOrdertotalCost.size()>0){    
                CurOrder.ShippingCostNonDomestic__c = lstSCNonDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c += lstSCOrdertotalCost[0].Charge__c;                      
                CurOrder.ShippingCostDomestic__c  = 0; 
                system.debug('**lstSCNonDomesticWeight**'+ lstSCNonDomesticWeight[0].Charge__c);
            }                  
            else if(lstSCDomesticWeight != null && lstSCDomesticWeight.size() > 0 && lstSCOrdertotalCost != null && lstSCOrdertotalCost.size()>0){
                CurOrder.ShippingCostDomestic__c = lstSCDomesticWeight[0].Charge__c; 
                CurOrder.ShippingCost__c = lstSCDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c += lstSCOrdertotalCost[0].Charge__c;                        
                CurOrder.ShippingCostNonDomestic__c  = 0;
                system.debug('**lstSCDomesticWeight**'+ lstSCDomesticWeight[0].Charge__c);
            }
            else if(lstSCNonDomesticWeight != null && lstSCNonDomesticWeight.size() > 0){    
                CurOrder.ShippingCostNonDomestic__c = lstSCNonDomesticWeight[0].Charge__c;
                CurOrder.ShippingCost__c = lstSCNonDomesticWeight[0].Charge__c;                      
                CurOrder.ShippingCostDomestic__c  = 0; 
                system.debug('**lstSCNonDomesticWeight**'+ lstSCNonDomesticWeight[0].Charge__c);
            }                  
            else if(lstSCDomesticWeight != null && lstSCDomesticWeight.size() > 0){
                CurOrder.ShippingCostDomestic__c = lstSCDomesticWeight[0].Charge__c; 
                CurOrder.ShippingCost__c = lstSCDomesticWeight[0].Charge__c;                        
                CurOrder.ShippingCostNonDomestic__c  = 0;
                system.debug('**lstSCDomesticWeight**'+ lstSCDomesticWeight[0].Charge__c);
            }
            else if(lstSCOrdertotalCost != null && lstSCOrdertotalCost.size() > 0){
                CurOrder.ShippingCost__c = lstSCOrdertotalCost[0].Charge__c;
                CurOrder.ShippingCostDomestic__c  = 0;
                CurOrder.ShippingCostNonDomestic__c = 0;
            }
            else{
                CurOrder.ShippingCost__c =0 ;
                CurOrder.ShippingCostDomestic__c = 0;
                CurOrder.ShippingCostNonDomestic__c = 0;
            }
    
           system.debug('**CurOrder.ShippingCost__c**'+ CurOrder.ShippingCost__c);
    
       // UTIL_TriggerController.OrderItemTriggerSwitch = false;
        update CurOrder;
    
        return CurOrder;
    
    }
    
    
        /*BULK Handling
        Public static List<OrderItem> UpdateShippingCostsFromItems (List<OrderItem> lstOrderItem){
    
                Map<String,Decimal> Map_NonDomesticWeight = new Map<String,Decimal>();
                Map<String,Decimal> Map_DomesticWeight = new Map<String,Decimal>();
                Map<String,String> Map_OperatingCompany = new Map<String,String>();
    
    
                for(OrderItem item:lst_OrderItemSelected){
                 
                    if( item.ShippingIndicationRule__c == 'Based on weight Domestic' && item.Weight__c > 0){
                        Map_OperatingCompany.add(item.OrderId,item.Order.Billto__r.OperatingCompany__c);
                        
                        if(Map_DomesticWeight.get(item.OrderId)==null){
                            Map_DomesticWeight.put(item.OrderId,item.Weight__c);
                        }
                        else{
                            Map_DomesticWeight.put(item.OrderId,Map_DomesticWeight.get(item.OrderId)+item.Weight__c);
                        }
                        
                    }
                    else if(item.ShippingIndicationRule__c == 'Based on weight non Domestic' && item.Weight__c > 0){
                        Map_OperatingCompany.add(item.OrderId,item.Order.Billto__r.OperatingCompany__c);
                        if(Map_NonDomesticWeight.get(item.OrderId)==null){
                            Map_NonDomesticWeight.put(item.OrderId,item.Weight__c);
                        }
                        else{
                            Map_NonDomesticWeight.put(item.OrderId,Map_NonDomesticWeight.get(item.OrderId)+item.Weight__c);
                        }
                    }
                    else if(item.ShippingIndicationRule__c =='Shipping Cost Exempt'){
    
                    }
                 
                }
          //      system.debug('**DomesticWeight**'+ DomesticWeight);
          //      system.debug('**NonDomesticWeight**'+ NonDomesticWeight);
                
                    ShippingCost__c[] lstShippingCostWeight = [Select Charge__c,ShippingRule__c From ShippingCost__c Where 
                    RangeValue__c <: NonDomesticWeight 
                    AND Subsidiary__c in: Set_OperatingCompany
                    AND (ShippingRule__c like: '%Based on weight non Domestic%' OR ShippingRule__c like: '%Based on weight Domestic%')
                    AND IsActive__c =: true
                    ORDER BY RangeValue__c DESC limit 1];
           
    
                    Map<String,Decimal> Map_ShippingCost = new Map<String,Decimal>();
                    Map<String,Decimal> Map_ShippingCostDomestic = new Map<String,Decimal>();
                    Map<String,Decimal> Map_ShippingCostNonDomestic = new Map<String,Decimal>();
    
                    for(String Ord:Map_OperatingCompany.keyset()){
    
                         
                            for(ShippingCost__c ship:lstShippingCostWeight){
    
                                if(ship.Subsidiary__c == Map_OperatingCompany.get(Ord)){ 
                                    if(ship.RangeValue__c < Map_DomesticWeight.get(Ord) && Map_ShippingCostDomestic.get(Ord) == null && ShippingRule__c.contains('Based on weight Domestic')){
                                        Map_ShippingCostDomestic.get(Ord)= ship.Charge__c;
                                    }
                                    if((ship.RangeValue__c < Map_NonDomesticWeight.get(Ord) && Map_ShippingCostNonDomestic.get(Ord) == null && ShippingRule__c.contains('Based on weight non Domestic')){
                                        Map_ShippingCostNonDomestic.get(Ord)= ship.Charge__c;
                                    }
                                }
                            }
    
                            if(Map_ShippingCostDomestic.get(Ord) != null && Map_ShippingCostNonDomestic.get(Ord) != null){
                                Map_ShippingCost.put(Map_ShippingCostDomestic.get(Ord)+Map_ShippingCostNonDomestic.get(Ord));
                            }
                            else if(Map_ShippingCostDomestic.get(Ord) != null){
                                Map_ShippingCost.put(Map_ShippingCostDomestic.get(Ord);
                            }
                            else if(Map_ShippingCostNonDomestic.get(Ord) != null){
                                Map_ShippingCost.put(Map_ShippingCostNonDomestic.get(Ord)
                            }
                    }
                   
                
                
               Order[] CurOrder = [Select ShippingCost__c,ShippingCostDomestic__c,ShippingCostNonDomestic__c from Order where in:Map_ShippingCost.keyset()];
               
               for(Order ord:CurOrder){
                    ord.ShippingCost__c = Map_ShippingCost.get(ord.id);
                    ord.ShippingCostDomestic__c = Map_ShippingCostDomestic.get(ord.id);
                    ord.ShippingCostNonDomestic__c = Map_ShippingCostNonDomestic.get(ord.id);
               }
               
               try{
                    UTIL_TriggerController.OrderItemTriggerSwitch = false;
                    Update CurOrder;
               }
               catch(exception e){
    
               }
               
    
               return lstOrderItem
            }       
            */
    }