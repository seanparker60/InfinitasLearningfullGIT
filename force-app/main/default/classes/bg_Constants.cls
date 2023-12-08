public class bg_Constants 
{
    public static final String DATE_FORMAT_YYYYMMDD = 'YYYY-MM-dd';
    public static final String ZUORA_TERM_TYPE_TERMED = 'TERMED';
    public static final String ZUORA_CANCEL_SUBSCRIPTION_SPECIFIED_DATE = 'SpecificDate';
    public static final String CREATE_SUBSCRIPTION_REST_RELATIVE_URL = '/rest/v1/subscriptions';
    public static final String CANCEL_SUBSCRIPTION_REST_RELATIVE_URL = '/rest/v1/subscriptions/{0}/cancel';
    public static final String CONNECTIONS_REST_RELATIVE_URL = '/rest/v1/connections';
    public static final String ZUORA_SUBSCRIPTION_QUICK_CHANGE_OPTION_CANCEL = 'CANCEL';
    public static final String ZUORA_SUBSCRIPTION_QUICK_CHANGE_OPTION_NO_ACTION = 'NO_ACTION';
    public static final String ZUORA_RECURRING_PERIOD_MONTH = 'Month';
    public static final String ZUORA_RECURRING_PERIOD_QUARTER = 'Quarter';
    public static final String ZUORA_RECURRING_PERIOD_ANNUAL = 'Annual';
    public static final String HTTP_CALLOUT_POST = 'POST';
    public static final String HTTP_CALLOUT_PUT = 'PUT';
    public static final String ZUORA_VF_QUOTE_BUILDER = '/apex/zqu__quoteoption?crmAccountId={0}&quoteType=Subscription&retUrl=%2F{0}&stepNumber=1';
/*    public static map<String, String> currencySymbolByISOCode 
    { 
        public get
        {
            return new map<String, String>{ 'GBP' => '£', 
                                            'USD' => '$',
                                            'CAD' => '$',
                                            'EUR' => '€',
                                            'JPY' => '¥',
                                            'KRW' => '₩',
                                            'CNY' => '元'};
        } 
    }
*/
    public static final String EMAIL_ORIGIN = 'Email';
    public static final String OPP_CLOSED_WON = 'Closed won';
    public static final String NEW_TYPE = 'New';
    public static final String RENEWAL_TYPE = 'Renewal';
    public static final String CONTRACT_FIRST_TIME_BUYER = 'First Time Buyer';
    public static final String CONTRACT_STATUS_DRAFT = 'Draft';
    public static final String CONTRACT_STATUS_ACTIVATED = 'Activated';
    public static final String CONTRACT_STATUS_TERMINATED = 'Terminated';
    public static final String CONTRACT_STATUS_EXPIRED = 'Expired';
    public static final String OPPORTUNITY_STAGENAME_PROPOSAL = 'Proposal';
    public static final String OPPORTUNITY_RENEWAL_SUFFIX = ' - Renewal';
    public static final String LEGAL_NAME_WUR_Inc = 'WUR Inc';
    public static final String LEGAL_NAME_SINGAPORE = 'Singapore Co';
    public static final String TAX_CODE_TEST1 = 'I-GB';
    public static final String TAX_CODE_TEST2 = 'EZ-GB';
    public static final String SUBSCRIPTION_CONTRACT_TYPE = 'Subscription';
    public static final String TRANSACTION_CONTRACT_TYPE = 'Transaction';
    public static final String BILLING_SCHEDULE_UPFRONT = 'Upfront';
}