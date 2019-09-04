public class TamsAccountIBUtilizationChartCTRL {
	public ID acctID {get;set;}
	public Account acct {get;set;}
	public List<AggregateResult> systemUtilData {get;set;}
	public String SeriesString {get;set;}
	public String drillDownString {get;set;}
	public String  displayEquipmentNames {get;set;}
	public String displayStudyDates {get;set;}
	public String displayCounts {get;set;} 
	public String selectedOption {get;set;}

	public TamsAccountIBUtilizationChartCTRL(ApexPages.StandardController stdController) 
	{
		System.debug('Inside: constructor TamsAccountIBUtilizationChartCTRL');		
		acctID = stdController.getId();
		System.debug('acctID:'+acctID);
		acct = [SELECT ID,NAME FROM Account WHERE id = :acctID LIMIT 1];
		selectedOption = ApexPages.currentPage().getParameters().get('selectedOption');
		System.debug('selectedOption:'+selectedOption);
		if(selectedOption == null)
			selectedOption = '5';

		try
		{
			systemUtilData = new List<AggregateResult>();
			Date fromDate = Date.today() - Integer.valueOf(selectedOption);
			Date toDate = Date.today();	
			systemUtilData =
				[SELECT
					Equipment_Lookup__r.name Equipment_Name,
					Equipment_Lookup__r.Nickname__c Nickname,
					DAY_ONLY(Study_Date__c) Equipment_Study_Date,
					COUNT(ID) total_count
				FROM
					TAMS_System_Utilization__c
				WHERE
					Account__c = :acctID
				AND Study_Date__c >= :fromDate
				AND Study_Date__c <= :toDate	
				GROUP BY
					Equipment_Lookup__r.name,
					Equipment_Lookup__r.Nickname__c,
					DAY_ONLY(Study_Date__c)
				ORDER BY
					Equipment_Lookup__r.name,
					Equipment_Lookup__r.Nickname__c,
				 	DAY_ONLY(Study_Date__c)
				];

			Set<String> equipmentNames = new Set<String>();
			displayCounts = '[';
			for(AggregateResult ar: systemUtilData)
			{
				equipmentNames.add((String)ar.get('Nickname')+':'+(String)ar.get('Equipment_Name'));
				String cnt = String.valueOf((Integer)ar.get('total_count'));
				displayCounts = displayCounts + cnt + ',';
			}	

			displayCounts = displayCounts.removeEnd(',');
			displayCounts = displayCounts + ']';

			List<String> orderedEquipmentNames = new List<String>(equipmentNames);
			orderedEquipmentNames.sort();

			displayEquipmentNames = '';
			for(String n: orderedEquipmentNames)
			{
				displayEquipmentNames = displayEquipmentNames + ''+ n + ',';
			}
			displayEquipmentNames = displayEquipmentNames.removeEnd(',');

			System.debug('displayEquipmentNames:'+displayEquipmentNames);	
			System.debug('After Equipment Names');	
			Set<Date> studyDates = new Set<Date>();

			for(AggregateResult ar: systemUtilData)
			{
				studyDates.add((Date)ar.get('Equipment_Study_Date'));
			}

			displayStudyDates = '[';
			for(Date d = fromDate; d < toDate ; d = d.addDays(1))
			{
				displayStudyDates = displayStudyDates + '\'' + String.valueOf(d.month()) + '-' + String.valueOf(d.day()) + '\'' + ',';
			}

			displayStudyDates = displayStudyDates.removeEnd(',');

			displayStudyDates = displayStudyDates + ']';
			System.debug('displayStudyDates:'+displayStudyDates);

			System.debug('After Dates');
			
			SeriesString = ' ';
			drillDownString = ' ';
			System.debug('SeriesString:'+SeriesString);
			for(String equipmentName: orderedEquipmentNames)
			{
				SeriesString = SeriesString + '{ name: '+'\''+ equipmentName + '\'' 
											+ ', drilldown:'+'\''+ equipmentName + '\'' 
											+ ', data: [ ';
				drillDownString = drillDownString + '{ id: '+'\''+ equipmentName + '\'' 
											+ ', data: [ ';											
				for(Date studyDate = fromDate; studyDate < toDate ; studyDate=studyDate.addDays(1))
				{
					Boolean recordExists = false;
					for(AggregateResult ar: systemUtilData)
					{	
						if((Date)ar.get('Equipment_Study_Date') == studyDate && ((String)ar.get('Nickname') +':'+(String)ar.get('Equipment_Name')) == equipmentName)
						{
							SeriesString = SeriesString + String.valueOf(ar.get('total_count')) + ',';
							drillDownString = drillDownString + '[' 
												+ studyDate.month()
												+ '-'
												+ studyDate.day()
												+ ','
												+ String.valueOf(ar.get('total_count')) + '],';
							recordExists = true;
						}

						
					}

					if (recordExists == false)
					{
							drillDownString = drillDownString + '['
												+ studyDate.month()
												+ '-'
												+ studyDate.day()
												+ ','
												+  '0],';						
						SeriesString = SeriesString + '0,';
					}
					System.debug('SeriesString:'+SeriesString);					
					System.debug('drillDownString:'+drillDownString);					
				}
				SeriesString = SeriesString.removeEnd(',');
				SeriesString = SeriesString + ']},';
				SeriesString = SeriesString + '\n';
				drillDownString = drillDownString.removeEnd(',');
				drillDownString = drillDownString + ']},';
				drillDownString = drillDownString + '\n';				
				System.debug('SeriesString:'+SeriesString);	
				System.debug('drillDownString:'+drillDownString);	
			}
			SeriesString = SeriesString.removeEnd(',\n');
			drillDownString = drillDownString.removeEnd(',\n');

			System.debug('END SeriesString:'+SeriesString);
			System.debug('END drillDownString:'+drillDownString);
		}
		catch(Exception e)
		{
			System.debug(e.getMessage());
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
				'Invalid Data Available for System Utilization – Please create a Web Support Case via General Inquiry.'));	 		
		} 
	}

   public PageReference refreshChart(){
   		System.debug('Inside: refresh');
   		System.debug('selectedOption:'+selectedOption);
        PageReference retPage = new PageReference('/apex/TamsAccountIBUtilizationChartVF?Id='+acctID+'&selectedOption='+selectedOption); 
        retPage.setRedirect(true);
        return retPage;        
    }		

   public PageReference returnBack(){
        PageReference retPage = new PageReference('/'+acctID); 
        retPage.setRedirect(true);
        return retPage;        
    }		
}