public with sharing class Order_AssetRenewalDatesInvoc {

    public class FlowInputs{
        @InvocableVariable public Boolean allowRenewal;
        @InvocableVariable public List<String> assetsIdList;
    }

    @InvocableMethod(label ='resetAssetsRenewalDates')
    public static void resetAssetsRenewalDates(List<FlowInputs> flowInputs) {
        system.debug('**Order_AssetRenewalDatesInvoc.resetAssetsRenewalDates**');

        //flowInputs[0].assetsIdList is the list of asset Ids received from the Order_Batch_AccountswithRenwalAssets assetIds collection variable
        List<Asset> assetList = [SELECT Id, RenewalDate__c, PreviousRenewalDate__c, AssetRenewalTrigger__c FROM Asset WHERE ID IN : flowInputs[0].assetsIdList];

        if(assetList != null && assetList.size() > 0){

            for(Asset asset : assetList){
                asset.RenewalDate__c = asset.PreviousRenewalDate__c != null ? asset.PreviousRenewalDate__c : asset.RenewalDate__c;
                asset.AssetRenewalTrigger__c = true;
            }

            //Reset the renewal dates on the assets
            update assetList;

            try{

                if(flowInputs[0].allowRenewal == true){
                    //Trigger the asset renewal process
                    Order_AssetRenewal.RenewAssets();
                }

            } catch (Exception e) {

                system.debug('**Order_AssetRenewalDatesInvoc.resetAssetsRenewalDates: Error**: ' + e.getStackTraceString());
                HandleCustomException.LogException(e, assetList[0].id);

            }
        }
    }
}