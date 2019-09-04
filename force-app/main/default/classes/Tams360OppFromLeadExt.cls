global class Tams360OppFromLeadExt {
    static final String RECORD_TYPE_TAMS = 'TAMS';
    static final String RECORD_TYPE_360_ASSIST = '360 Sales Assist';
    static final String STAGE_NAME = 'Milestone 2: In Play';
    static final String TAMS_AE_PPOBABILITY = 'Possible';
    @AuraEnabled
    webservice static String createOpportunity(ID leadID) {
        
        List<Lead> lead = [SELECT   FirstName,
                                    LastName,
                                    Name, 
                                    OwnerId, 
                                    Primary_Modality_TAMS__c,
                                    LeadSource,
                                    Existing_Account__c,
                                    email,
                                    Phone
                         FROM Lead 
                         WHERE id = :leadID LIMIT 1 ];
        if(lead.size()==0){
            return 'Error:Unable to find Lead ID:'+leadID;
        }             
        try{
            List<RecordType> recordTypes = [
                                            SELECT
                                                ID,Name
                                            FROM
                                                RecordType
                                            WHERE sObjectType= 'Opportunity'
                                            AND name = :RECORD_TYPE_TAMS
                                            LIMIT 1
                                            ];
            if (recordTypes.size()==0){
                return 'Error:Record Type "'+RECORD_TYPE_TAMS+'" not defined.';
            }
            /*
            Opportunity opp = New Opportunity();
            opp.RecordTypeId=recordTypes[0].ID;
            opp.Name = RECORD_TYPE_TAMS+':'+Lead[0].Name;
            opp.AccountId = Lead[0].Existing_Account__c;
            opp.StageName=STAGE_NAME;
            opp.CloseDate= System.today().addMonths(2);
            opp.OwnerID = Lead[0].OwnerId;
            opp.Modality_TAMS__c = Lead[0].Primary_Modality_TAMS__c;
            opp.LeadSource = Lead[0].LeadSource;
            opp.Expected_Bill_Date_TAMS__c = System.today().addMonths(2);
            opp.TAMS_AE_Probability__c = TAMS_AE_PPOBABILITY;
            insert Opp;
            */
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadID);
            //lc.setDoNotCreateOpportunity(false); 
            lc.setAccountId(Lead[0].Existing_Account__c);
            Id contactId = getContactId(Lead[0],Lead[0].Existing_Account__c);
            System.debug('contactId:'+contactId);
            if (contactId != null){
                lc.setContactId(contactId);
            }

            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);        

            if(lcr.isSuccess())
                return lcr.getOpportunityId();
            else
                return 'Error:During converting Lead. Errors:'+lcr.getErrors();
                    
            }
            Catch(Exception e){
            return 'Error:'+e.getMessage();
        }

    }

    private static Id getContactId(Lead lead, Id accountId){
        System.debug('START:getContactId');
        List<Contact> contacts = [SELECT Id FROM Contact 
                                  WHERE email = :lead.email
                                  AND AccountId = :accountId
                                  LIMIT 1 ];
        if (contacts.size() != 0){
            return contacts[0].Id;
        }    
        contacts = [SELECT Id FROM Contact 
                                  WHERE phone = :lead.phone
                                  AND AccountId = :accountId
                                  LIMIT 1 ];
        if (contacts.size() != 0){
            return contacts[0].Id;
        }    
        contacts = [SELECT Id FROM Contact 
                                  WHERE FirstName = :lead.FirstName
                                  AND LastName = :lead.LastName
                                  AND AccountId = :accountId
                                  LIMIT 1 ];

        if (contacts.size() != 0){
            return contacts[0].Id;
        }                                    
        
        return null;                                                                   
    }

    @AuraEnabled
    public static Lead[] getLeads(String status, String modality, String leadName, String accountName,String rank, String sortBy){
        System.debug('START:getLeads');
        System.debug('accountName:'+accountName);
        System.debug('status:'+status);
        System.debug('modality:'+modality);
        System.debug('leadName:'+leadName);
        System.debug('rank:'+rank);
        System.debug('sortBy:'+sortBy);
        List<String> allStatusValues = new List<String>();
        allStatusValues.addAll(status.split(';'));
        System.debug('allStatusValues:'+allStatusValues);    
        String queryString = 'SELECT Name, Existing_Account__r.Name,Existing_Account__c,Status,Rank_PIcklist__c,Primary_Modality_TAMS__c FROM Lead ';
        //Status is a required field
        String statusClause = ' WHERE status IN (';
        for(String val:allStatusValues){
            statusClause += '\''+val+'\''+',';
        }
        statusClause = statusClause.removeEnd(',');
        statusClause += ')';
        System.debug('statusClause:'+statusClause);    
        String accountNameClause = '';
        if(accountName == null){
            accountNameClause = ' ';
        }
        else{
            accountNameClause = ' AND Existing_Account__r.Name like \'%'+accountName+'%\'';
        }

        System.debug('accountNameClause:'+accountNameClause);    
        String modalityClause = '';
        if(modality == null || modality == 'All'){
            modalityClause = ' ';
        }else{
            modalityClause = ' AND Primary_Modality_TAMS__c = \''+modality+'\'';
        }

        System.debug('modalityClause:'+modalityClause); 
        String leadNameClause = '';
        if(leadName == null){
            leadNameClause = ' ';        
        }else{
            leadNameClause = ' AND Name like \'%'+leadName+'%\'';        
        }
        System.debug('leadNameClause:'+leadNameClause);     

        String rankClause = '';
        if(rank == null || rank == 'All'){
            rankClause = ' ';        
        }else{
            rankClause = ' AND Rank_PIcklist__c = \''+rank+'\'';        
        }
        System.debug('rankClause:'+rankClause);

        String sortByClause='';
        if(sortBy == 'Rank')
            sortByClause = ' ORDER BY Rank_PIcklist__c';
        else if (sortBy == 'Status')
            sortByClause = ' ORDER BY Status';
        else if (sortBy == 'Modality')
            sortByClause = ' ORDER BY Primary_Modality_TAMS__c';
        else if (sortBy == 'Account Name')
            sortByClause = ' ORDER BY Existing_Account__r.Name';
        else
            sortByClause = ' ORDER BY Name';

        String recordTypeClause = ' AND RecordType.Name = \''+RECORD_TYPE_360_ASSIST+'\'';
        queryString += statusClause + accountNameClause + modalityClause + leadNameClause + rankClause + recordTypeClause + sortByClause;
        System.debug('queryString:'+queryString);     
        List<Lead> leads = Database.Query(queryString);
        return leads;
    }

}