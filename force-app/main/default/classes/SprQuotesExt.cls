public with sharing class SprQuotesExt {
    private TAMS_Special_Pricing_Request__c spr;
    public List<SprQuotesWrapper> sprQuotes = new List<SprQuotesWrapper>();
    List<TamsQuoteWrapper> queriedQuotes {get;set;}
    public SprQuotesExt(ApexPages.StandardController stdController) {
        System.debug('Inside:SprQuotesExt');
        RerenderPage = 'quotes,sprBlock,showMsg,queryQuotes,panel';
        queriedQuotes=new List<TamsQuoteWrapper>();
        this.spr =  (TAMS_Special_Pricing_Request__c)stdController.getRecord(); 
        sprQuotes = new List<SprQuotesWrapper>();
        System.Debug('spr:'+spr);    
        if(spr.Id==null){
            
            quoteId=(Id)ApexPages.currentPage().getParameters().get('QuoteId');
            System.Debug('quoteId:'+quoteId);           
            quotes=[SELECT Customer_Name__c,Modality__c FROM TAMS_Quotes__c WHERE id =:quoteId LIMIT 1];
            this.spr.TAMS_Quote_SPR__c = quoteId;
            this.spr.Requested_Response_Date_SPR__c = System.TODAY();
            this.spr.Delivery_Date_SPR__c = System.TODAY()  + 30;          
            this.spr.Multi_Modality__c = quotes[0].Modality__c;
        }
    }
    
    public List<TamsQuoteWrapper> getQueriedQuotes()
    {
        queriedQuotes= new List<TamsQuoteWrapper>(); 
        for(TAMS_Quotes__c q:(List<TAMS_Quotes__c>)controllerSet.getRecords())
        {
            TamsQuoteWrapper tamsQWrapper = new TamsQuoteWrapper(q);
            queriedQuotes.add(tamsQWrapper);
        }
        return queriedQuotes;
     }
     
    public boolean hasNext
        {
            get
            {
                if(controllerSet==null)
                    return false;
                return controllerSet.getHasNext();
            }
            set;
        } 

    public boolean hasPrevious
        {
            get
            {
                if(controllerSet==null)
                    return false;                   
                return controllerSet.getHasPrevious();
            }
            set;
        }           
    public Integer pageNumber
    {
        get
        {
            if(controllerSet==null)
                    return 0;               
            return controllerSet.getPageNumber();
        }   
        set;
    }
    
    public List<SprQuotesWrapper> deleteSprQuotes = new List<SprQuotesWrapper>();
    public String querySID {get;set;}
    public String queryAccount {get;set;}
    public String queryModality {get;set;}
    public String queryQuoteNumber {get;set;} 

    
    
    private Id quoteId;   
    private List<TAMS_Quotes__c> quotes;
    public String RerenderPage {get;set;}
    
    public pagereference save()
    {
        System.debug('Inside:save');
        upsert spr;
        PageReference newPage=new PageReference('/'+spr.ID);
        return newPage.setRedirect(true);
    }
    
    public pagereference saveSpr()
    {
        System.debug('Inside:saveSpr spr.Id:'+spr.Id);
        if(spr.Id==null)
        {
            spr.Bundled_SPR__c = 'No';
            spr.TAMS_Quote_SPR__c = quoteId;       
            insert spr; 
            SPR_Quote__c sprQ=new SPR_Quote__c(TAMS_SPR__c = spr.Id); 
            sprQ.Account_SPR__c = [SELECT Customer_Name__c FROM TAMS_Quotes__c WHERE ID=:QuoteId LIMIT 1][0].Customer_Name__c ;
            sprQ.TAMS_Quote_SPR__c=quoteId;
            sprQ.Primary__c = true;
            sprQuotes.add(new SprQuotesWrapper(sprQ));
            List<SPR_Quote__c> sprList = new List<SPR_Quote__c>();
            for(Integer i=0; i<sprQuotes.size(); i++)
            {
                sprList.add(sprQuotes[i].sprQuote);
            }    
            insert sprList;
            PageReference returnPage = new PageReference('/apex/SprPage?Id='+this.spr.Id);
            returnPage.setRedirect(true);
            return returnPage;
        }
        else 
        {
            try{
                upsert spr;
            }catch(DMLException e)
            {
                System.debug('e.message:'+e.getMessage());
                PageReference newPage=new PageReference('/'+spr.ID);
                newPage.setRedirect(true);
                newPage.getParameters().put('hasError','true');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have access to edit this record.'));
                return newPage;
            }
            queryAccount=spr.Account__c;
            return null;
        }
        
    }    
    public pagereference addQuote()
    {
        System.debug('Inside:addQuote');
        System.debug('queriedQuotes.size():'+queriedQuotes.size());
        for(Integer i=0; i<queriedQuotes.size(); i++)
        {
            System.debug('Oracle_Quote_Number__c:'+queriedQuotes[i].tamsQuote.Oracle_Quote_Number__c);
            System.debug('selected:'+queriedQuotes[i].selected);
            if(queriedQuotes[i].selected)
            {
                System.debug('adding selected quote...');
                SprQuotesWrapper q=new SprQuotesWrapper(new SPR_Quote__c(TAMS_SPR__c = spr.Id));
                q.sprQuote.Account_SPR__c = queriedQuotes[i].tamsQuote.Customer_Name__c;
                q.sprQuote.TAMS_Quote_SPR__c = queriedQuotes[i].tamsQuote.ID;
                sprQuotes.add(q);
            }
                
        }
       System.debug('sprQuotes.size():'+sprQuotes.size()); 
       queriedQuotes.clear(); 
       return saveChanges();
    }  
    
    public List<SprQuotesWrapper> getsprQuotes()
    {
        System.debug('Inside:getsprQuotes');
        List<SPR_Quote__c> baseQuotes = new List<SPR_Quote__c>();
        if(sprQuotes.size()==0)
        { baseQuotes=[SELECT  Account_SPR__c,APPROVED_Selling_Price__c,Discount_SPR__c,Gross_Margin_SPR__c,
                      List_Price_SPR__c,Modality_SPRQ__c,Oracle_Quote__c,PBOM_SPR__c,Primary__c,QFA_Discount_SPR__c,Selling_Price_SPR__c,
                      SID_SPR__c,TAMS_Quote_SPR__r.Customer_Name__c,TAMS_Quote_SPR__r.ID,TAMS_Quote_SPR__r.NAME,SPR_Comments__c
                      ,TAMS_Quote_SPR__c,TAMS_SPR__c,Trade_In__c,Opprtunity_Number__c,AE_Name__c,ZBM_Name__c,
                      LastModifiedById,OwnerId,Name,CreatedById FROM SPR_Quote__c WHERE TAMS_SPR__c = :spr.Id ];
        }
        for(Integer i=0;i<baseQuotes.size();i++)
        {
            sprQuotes.add(new SprQuotesWrapper(baseQuotes[i])) ;
        }
        return sprQuotes;
    } 
    
    public pagereference removeQuote()
    {
        System.debug('Inside:removeQuote');
        String s=checkPrimaryFlag();
        System.debug('checkPrimaryFlag error flag:'+s);
        if(s=='E')
            return null;
        List<SPR_Quote__c> sprListDel = new List<SPR_Quote__c>();
        for(Integer i=0; i<SprQuotes.size(); i++)
        {   
            if(SprQuotes[i].selected)
                sprListDel.add(SprQuotes[i].sprQuote);
        }
        System.debug('sprListDel.size():'+sprListDel.size());
        System.debug('SprQuotes.size():'+SprQuotes.size());
        if( sprListDel.size() == SprQuotes.size())
        {
            spr.addError('SPR should contain at least one quote.');
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'SPR should contain at least one quote.'));
            return null;
        }
        if( SprQuotes.size() - sprListDel.size() == 1) //One one quote remains. Make it primary
        {
            for(Integer x = 0; x < SprQuotes.size(); x++)
            {
                Boolean remainingQ = true;
                System.debug('x:'+x);
                System.debug('SprQuotes[x].sprQuote.NAME:'+SprQuotes[x].sprQuote.NAME);
                for(Integer y = 0; y < sprListDel.size() ; y++)
                {    
                    System.debug('y:'+y);
                    System.debug('sprListDel[y].NAME:'+sprListDel[y].NAME);
                    if(SprQuotes[x].sprQuote.id == sprListDel[y].id)
                    {    
                        remainingQ = false;
                        break;
                    }
                }    
                System.debug('remainingQ:'+remainingQ);
                if(remainingQ)
                {    
                    spr.TAMS_Quote_SPR__c = SprQuotes[x].sprQuote.TAMS_Quote_SPR__c;        
                    SprQuotes[x].sprQuote.Primary__c = true;  
                    update spr;
                    update SprQuotes[x].sprQuote;
                }
            }    
        }
        System.debug('After sprListDel size check for last quote');
        if( sprListDel.size() > 0)
        {
            delete sprListDel;
            System.debug('After sprListDel deletion');
        }
        PageReference returnPage = new PageReference('/apex/SprPage?Id='+this.spr.Id);
        returnPage.setRedirect(true);
        return returnPage;
        
    }
    
    
    public pagereference saveChanges()
    {
        System.debug('Inside:saveChanges');
        String dupStringFlag = checkDuplicateQuote();
        System.debug('dupStringFlag:'+dupStringFlag);
        String priStringFlag = checkPrimaryFlag();
        System.debug('priStringFlag:'+priStringFlag); 
        if(dupStringFlag =='E' || priStringFlag =='E' )
        {
            for(Integer x=0; x < sprQuotes.size(); x++)
            {
                if(sprQuotes[x].sprQuote.ID==null)
                    sprQuotes.remove(x);
            }
            return null;
        }
            
        upsert spr;
        
        List<SPR_Quote__c> sprList = new List<SPR_Quote__c>();
        for(Integer i=0; i<sprQuotes.size(); i++)
        {
            sprList.add(sprQuotes[i].sprQuote);
        }    
        if( SprQuotes.size() == 1)
        {
            spr.TAMS_Quote_SPR__c = SprQuotes[0].sprQuote.TAMS_Quote_SPR__c;        
            SprQuotes[0].sprQuote.Primary__c = true;
        }
        
        upsert sprList;
        
        queriedQuotes.clear(); 
        PageReference returnPage = new PageReference('/apex/SprPage?Id='+this.spr.Id);
        returnPage.setRedirect(true);
        return returnPage;
        
    } 
    
    public ApexPages.StandardSetController controllerSet
        { set;
            get
            {
                if(controllerSet==null)
                {               
                    String columnString;
                    columnString=' ID,';
                    for(Schema.FieldSetMember fsm : SObjectType.TAMS_Quotes__c.FieldSets.Quote_Columns_for_SPR_Page.getFields())
                    {
                        columnString = columnString+fsm.getFieldPath()+',';
                    }
                    columnString=columnString.removeEnd(','); 
                    String excludeStatus = ' Status__c NOT IN (\'Closed-Converted to New Order\',\'Order Submitted\')';
                    System.debug('columnString:'+columnString); 
                    System.debug('excludeStatus:'+excludeStatus);
                    String queryString='SELECT '+columnString+' FROM TAMS_Quotes__c '+
                                        ' WHERE '+ excludeStatus;
                    if(querySID!='')                    
                        queryString+= ' AND SID__c =\''+querySID+'\'';
                    if(queryAccount!='')
                        queryAccount=String.escapeSingleQuotes(queryAccount); //HK updated on 4/29/2019
                        queryString+= ' AND   Customer_Name__r.Name LIKE \'%'+queryAccount+'%\'';
                    if(queryModality!='')
                        queryString+= ' AND   Modality__c = \''+queryModality+'\'';
                    if(queryQuoteNumber!='')
                        queryString+= ' AND   Oracle_Quote_Number__c = \''+queryQuoteNumber+'\'';
                    System.debug(queryString) ;
                    List<TAMS_Quotes__c> queryResult= new List<TAMS_Quotes__c>();               
                    controllerSet = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    controllerSet.setPageSize(5);
                }
                return controllerSet;
            }   
        } 

    public void first()
    {
        controllerSet.first();
    }   
    public void last()
    {
        controllerSet.last();
    }               
    public void next()
    {
        controllerSet.next();
    }                   
    public void previous()
    {
        controllerSet.previous();
    }                       
    public PageReference search()
    {
        System.debug('Inside:search');
        System.debug('queryAccount:'+queryAccount);
        System.debug('querySID:'+querySID);
        System.debug('queryQuoteNumber:'+queryQuoteNumber);
        if(queryAccount==''&&querySID==''&&queryQuoteNumber=='')
        {
           System.debug('Inside error for acct,SID,quote # not defined');
           spr.addError('Please specify at least one of these fields: Account, SID or Quote Number.');
           Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please specify at least one of these fields: Account, SID or Quote Number.'));
           return null;         
        }
        controllerSet=null;  //reset controller set
        first();
        return null;
    }
    
    private String checkDuplicateQuote()
    {   
        System.debug('Inside:checkDuplicateQuote');
        String s='S';
        Map<String,String> existingQuotes = new Map<String,String>();
        for(SprQuotesWrapper q:sprQuotes) 
        {
            existingQuotes.put(q.sprQuote.TAMS_Quote_SPR__r.ID, q.sprQuote.TAMS_Quote_SPR__r.Name);
        }
     
        for(Integer i=0;i<sprQuotes.size();i++)
        {   
            for(Integer j=0;j<sprQuotes.size();j++)
            {    
                System.debug('sprQuotes.get(i).sprQuote.TAMS_Quote_SPR__c:'+sprQuotes.get(i).sprQuote.TAMS_Quote_SPR__c);
                System.debug('sprQuotes.get(j).sprQuote.TAMS_Quote_SPR__c:'+sprQuotes.get(j).sprQuote.TAMS_Quote_SPR__c);
                System.debug('i:'+i);
                System.debug('j:'+j);
                if(sprQuotes.get(i).sprQuote.TAMS_Quote_SPR__c==sprQuotes.get(j).sprQuote.TAMS_Quote_SPR__c && j!=i)
                {
                    spr.addError('Duplicate quotes. Quote Number:'+sprQuotes.get(i).sprQuote.TAMS_Quote_SPR__r.Name);
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Duplicate quotes. Quote Number:'+sprQuotes.get(i).sprQuote.TAMS_Quote_SPR__r.Name));
                    return 'E';                
                }
            }
        }
        return s;
    }
    
    public PageReference switchPrimary()
    {
        System.debug('Inside:switchPrimary');
        for(Integer i=0; i<SprQuotes.size(); i++)
        {   
            if(SprQuotes[i].primarySelected)
                SprQuotes[i].sprQuote.Primary__c=true;
            else
                SprQuotes[i].sprQuote.Primary__c=false;
        }
        return saveChanges();           
    }
    
    private String checkPrimaryFlag()
    {
        System.debug('Inside:checkPrimaryFlag');
        List<SPR_Quote__c> sprListPri = new List<SPR_Quote__c>();
        for(Integer i=0; i < SprQuotes.size(); i++)
        {   
            System.debug('SprQuotes[i].sprQuote.id:'+SprQuotes[i].sprQuote.id);
            System.debug('SprQuotes[i].sprQuote.Primary__c:'+SprQuotes[i].sprQuote.Primary__c);
            if(SprQuotes[i].sprQuote.Primary__c)
                sprListPri.add(SprQuotes[i].sprQuote);
        }   
        System.debug('sprListPri.size():'+sprListPri.size());        
        if(sprListPri.size() > 1)
        {
            System.debug('Only one quote can be primary');
            spr.addError('Only one quote can be primary');
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only one quote can be primary'));
            return 'E';
        }
        else if( sprListPri.size() == 0)
        {
            System.debug('At lease one quote should be primary');
            spr.addError('At lease one quote should be primary');  
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'At lease one quote should be primary'));
            return 'E';
        }
        else
        {
            spr.TAMS_Quote_SPR__c = sprListPri[0].TAMS_Quote_SPR__c;
        }
    
        return 'S';
        
    }
}