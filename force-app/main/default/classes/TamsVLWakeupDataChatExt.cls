public class TamsVLWakeupDataChatExt {
  public List<VL_Wake_Up_Data__c> weakupRecords {get;set;}
  
  public ID      vlwdid       {get;set;}
  public String  productCode  {get;set;}
  public Date    readingDate  {get;set;}
  public Date    baseDate     {get;set;}
  public String  TubeType     {get;set;}
  public String  SystemType   {get;set;}

  public String fRecColor     {get;set;}
  public String fDsaColor     {get;set;}
  public String fDaColor      {get;set;}
  public String lRecColor     {get;set;}
  public String lDsaColor     {get;set;}
  public String lDaColor      {get;set;} 

  public String F_REC_kV      {get;set;}
  public String F_REC_mA      {get;set;}
  public String F_REC_Pix     {get;set;}
  public String F_REC_msec    {get;set;}
  public String F_REC_Dose    {get;set;}

  public String F_DA_kV      {get;set;}
  public String F_DA_mA      {get;set;}
  public String F_DA_Pix     {get;set;}
  public String F_DA_msec    {get;set;}
  public String F_DA_Dose    {get;set;}
  
  public String F_DSA_kV      {get;set;}
  public String F_DSA_mA      {get;set;}
  public String F_DSA_Pix     {get;set;}
  public String F_DSA_msec    {get;set;}
  public String F_DSA_Dose    {get;set;}  
   
  public String L_REC_kV      {get;set;}
  public String L_REC_mA      {get;set;}
  public String L_REC_Pix     {get;set;}
  public String L_REC_msec    {get;set;}
  public String L_REC_Dose    {get;set;}

  public String L_DA_kV      {get;set;}
  public String L_DA_mA      {get;set;}
  public String L_DA_Pix     {get;set;}
  public String L_DA_msec    {get;set;}
  public String L_DA_Dose    {get;set;}
  
  public String L_DSA_kV      {get;set;}
  public String L_DSA_mA      {get;set;}
  public String L_DSA_Pix     {get;set;}
  public String L_DSA_msec    {get;set;}
  public String L_DSA_Dose    {get;set;}     

  public String  F_REC_kV_Base    {get;set;}
  public String  F_REC_kV_Value   {get;set;}
  public String  F_REC_kV_Name    {get;set;}
  public String  F_REC_mA_Base    {get;set;}
  public String  F_REC_mA_Value   {get;set;}
  public String  F_REC_mA_Name    {get;set;}
  public String  F_REC_Pix_Base   {get;set;}
  public String  F_REC_Pix_Value  {get;set;}
  public String  F_REC_Pix_Name   {get;set;}
  public String  F_REC_Msec_Base  {get;set;}
  public String  F_REC_Msec_Value {get;set;}
  public String  F_REC_Msec_Name  {get;set;}
  public String  F_REC_Dose_Base  {get;set;}
  public String  F_REC_Dose_Value {get;set;}
  public String  F_REC_Dose_Name  {get;set;}

  public String  F_DA_kV_Base    {get;set;}
  public String  F_DA_kV_Value   {get;set;}
  public String  F_DA_kV_Name    {get;set;}
  public String  F_DA_mA_Base    {get;set;}
  public String  F_DA_mA_Value   {get;set;}
  public String  F_DA_mA_Name    {get;set;}
  public String  F_DA_Pix_Base   {get;set;}
  public String  F_DA_Pix_Value  {get;set;}
  public String  F_DA_Pix_Name   {get;set;}
  public String  F_DA_Msec_Base  {get;set;}
  public String  F_DA_Msec_Value {get;set;}
  public String  F_DA_Msec_Name  {get;set;}
  public String  F_DA_Dose_Base  {get;set;}
  public String  F_DA_Dose_Value {get;set;}
  public String  F_DA_Dose_Name  {get;set;}  
  
  public String  F_DSA_kV_Base    {get;set;}
  public String  F_DSA_kV_Value   {get;set;}
  public String  F_DSA_kV_Name    {get;set;}
  public String  F_DSA_mA_Base    {get;set;}
  public String  F_DSA_mA_Value   {get;set;}
  public String  F_DSA_mA_Name    {get;set;}
  public String  F_DSA_Pix_Base   {get;set;}
  public String  F_DSA_Pix_Value  {get;set;}
  public String  F_DSA_Pix_Name   {get;set;}
  public String  F_DSA_Msec_Base  {get;set;}
  public String  F_DSA_Msec_Value {get;set;}
  public String  F_DSA_Msec_Name  {get;set;}
  public String  F_DSA_Dose_Base  {get;set;}
  public String  F_DSA_Dose_Value {get;set;}
  public String  F_DSA_Dose_Name  {get;set;} 
  
  public String  L_REC_kV_Base    {get;set;}
  public String  L_REC_kV_Value   {get;set;}
  public String  L_REC_kV_Name    {get;set;}
  public String  L_REC_mA_Base    {get;set;}
  public String  L_REC_mA_Value   {get;set;}
  public String  L_REC_mA_Name    {get;set;}
  public String  L_REC_Pix_Base   {get;set;}
  public String  L_REC_Pix_Value  {get;set;}
  public String  L_REC_Pix_Name   {get;set;}
  public String  L_REC_Msec_Base  {get;set;}
  public String  L_REC_Msec_Value {get;set;}
  public String  L_REC_Msec_Name  {get;set;}
  public String  L_REC_Dose_Base  {get;set;}
  public String  L_REC_Dose_Value {get;set;}
  public String  L_REC_Dose_Name  {get;set;}

  public String  L_DA_kV_Base    {get;set;}
  public String  L_DA_kV_Value   {get;set;}
  public String  L_DA_kV_Name    {get;set;}
  public String  L_DA_mA_Base    {get;set;}
  public String  L_DA_mA_Value   {get;set;}
  public String  L_DA_mA_Name    {get;set;}
  public String  L_DA_Pix_Base   {get;set;}
  public String  L_DA_Pix_Value  {get;set;}
  public String  L_DA_Pix_Name   {get;set;}
  public String  L_DA_Msec_Base  {get;set;}
  public String  L_DA_Msec_Value {get;set;}
  public String  L_DA_Msec_Name  {get;set;}
  public String  L_DA_Dose_Base  {get;set;}
  public String  L_DA_Dose_Value {get;set;}
  public String  L_DA_Dose_Name  {get;set;}  
  
  public String  L_DSA_kV_Base    {get;set;}
  public String  L_DSA_kV_Value   {get;set;}
  public String  L_DSA_kV_Name    {get;set;}
  public String  L_DSA_mA_Base    {get;set;}
  public String  L_DSA_mA_Value   {get;set;}
  public String  L_DSA_mA_Name    {get;set;}
  public String  L_DSA_Pix_Base   {get;set;}
  public String  L_DSA_Pix_Value  {get;set;}
  public String  L_DSA_Pix_Name   {get;set;}
  public String  L_DSA_Msec_Base  {get;set;}
  public String  L_DSA_Msec_Value {get;set;}
  public String  L_DSA_Msec_Name  {get;set;}
  public String  L_DSA_Dose_Base  {get;set;}
  public String  L_DSA_Dose_Value {get;set;}
  public String  L_DSA_Dose_Name  {get;set;} 
  
  
  public string colorIndicator(Integer Ind)
  {
    if (Ind == 0)
      {return 'Green';}
    else if (Ind == 1)
      {return 'Red';}
    else
      {return null;}  
  }           
  
  public TamsVLWakeupDataChatExt(ApexPages.StandardController stdController) {
    ID ibID = stdController.getId();    
    //System.debug('HK inside page constructor TamsVLWakeupDataChatExt');   
    try{
      Install_Base_TAMS__c ibRecord = 
          [SELECT id, SID_TAMS__c, TAMS_Product_Lookup_TAMS__r.Name 
          FROM Install_Base_TAMS__c 
          WHERE ID = :ibID];
      productCode = ibRecord.TAMS_Product_Lookup_TAMS__r.Name;    

      weakupRecords = [SELECT 
                       id,
                       rmtype__c, 
                       acqdate__c,
                       base_reading_date__c, 
                       f_tubetype__c,
                       l_tubetype__c, 
                       l_f_rec_msec_ind__c,
                       l_f_rec_ma_ind__c, 
                       l_f_rec_kv_ind__c, 
                       l_f_rec_time_ind__c,
                       l_f_rec_pix_ind__c, 
                       l_f_rec_dose_ind__c, 
                       l_dsa_msec_ind__c,
                       l_dsa_ma_ind__c, 
                       l_dsa_kv_ind__c, 
                       l_dsa_time_ind__c,
                       l_dsa_pix_ind__c, 
                       l_dsa_dose_ind__c, 
                       l_da_msec_ind__c,
                       l_da_ma_ind__c, 
                       l_da_kv_ind__c, 
                       l_da_time_ind__c,
                       l_da_pix_ind__c, 
                       l_da_dose_ind__c,       
                       f_f_rec_msec_ind__c, 
                       f_f_rec_ma_ind__c, 
                       f_f_rec_kv_ind__c,
                       f_f_rec_time_ind__c, 
                       f_f_rec_pix_ind__c, 
                       f_f_rec_dose_ind__c,
                       f_dsa_msec_ind__c, 
                       f_dsa_ma_ind__c, 
                       f_dsa_kv_ind__c,
                       f_dsa_time_ind__c, 
                       f_dsa_pix_ind__c, 
                       f_dsa_dose_ind__c,
                       f_da_msec_ind__c, 
                       f_da_ma_ind__c, 
                       f_da_kv_ind__c,
                       f_da_time_ind__c, 
                       f_da_pix_ind__c, 
                       f_da_dose_ind__c,
                       frontal_ind__c,
                       Frontal_F_DA_Ind__c,
                       Frontal_F_DSA_Ind__c,
                       Frontal_F_REC_Ind__c,
                       lateral_ind__c,
                       Lateral_L_DA_Ind__c,
                       Lateral_L_DSA_Ind__c,
                       Lateral_L_REC_Ind__c,                       
                       Base_F_DA_DOSE__c,
                       Base_F_DA_kV__c,
                       Base_F_DA_mA__c,
                       Base_F_DA_msec__c,
                       Base_F_DA_Pix__c,
                       Base_F_DA_Time__c,
                       Base_F_DSA_DOSE__c,
                       Base_F_DSA_kV__c,
                       Base_F_DSA_mA__c,
                       Base_F_DSA_msec__c,
                       Base_F_DSA_Pix__c,
                       Base_F_DSA_Time__c,
                       Base_F_F_REC_DOSE__c,
                       Base_F_F_REC_kV__c,
                       Base_F_F_REC_mA__c,
                       Base_F_F_REC_msec__c,
                       Base_F_F_REC_Pix__c,
                       Base_F_F_REC_Time__c,
                       Base_L_DA_DOSE__c,
                       Base_L_DA_kV__c,
                       Base_L_DA_mA__c,
                       Base_L_DA_msec__c,
                       Base_L_DA_Pix__c,
                       Base_L_DA_Time__c,
                       Base_L_DSA_DOSE__c,
                       Base_L_DSA_kV__c,
                       Base_L_DSA_mA__c,
                       Base_L_DSA_msec__c,
                       Base_L_DSA_Pix__c,
                       Base_L_DSA_Time__c,
                       Base_L_F_REC_DOSE__c,
                       Base_L_F_REC_kV__c,
                       Base_L_F_REC_mA__c,
                       Base_L_F_REC_msec__c,
                       Base_L_F_REC_Pix__c,
                       Base_L_F_REC_Time__c,                       
                       F_DA_DOSE__c,
                       F_DA_kV__c,
                       F_DA_mA__c,
                       F_DA_msec__c,
                       F_DA_Pix__c,
                       F_DA_Time__c,
                       F_DSA_DOSE__c,
                       F_DSA_kV__c,
                       F_DSA_mA__c,
                       F_DSA_msec__c,
                       F_DSA_Pix__c,
                       F_DSA_Time__c,
                       F_F_REC_DOSE__c,
                       F_F_REC_kV__c,
                       F_F_REC_mA__c,
                       F_F_REC_msec__c,
                       F_F_REC_Pix__c,
                       F_F_REC_Time__c,
                       L_DA_DOSE__c,
                       L_DA_kV__c,
                       L_DA_mA__c,
                       L_DA_msec__c,
                       L_DA_Pix__c,
                       L_DA_Time__c,
                       L_DSA_DOSE__c,
                       L_DSA_kV__c,
                       L_DSA_mA__c,
                       L_DSA_msec__c,
                       L_DSA_Pix__c,
                       L_DSA_Time__c,
                       L_F_REC_DOSE__c,
                       L_F_REC_kV__c,
                       L_F_REC_mA__c,
                       L_F_REC_msec__c,
                       L_F_REC_Pix__c,
                       L_F_REC_Time__c
                FROM VL_Wake_Up_Data__c
                WHERE SID__c = :ibRecord.SID_TAMS__c
                ORDER BY acqDate__c DESC
                LIMIT 1];  

      vlwdid      = weakupRecords[0].id; 
      readingDate = weakupRecords[0].acqdate__c; 
      baseDate    = weakupRecords[0].base_reading_date__c;
      TubeType    = weakupRecords[0].f_tubetype__c; 
      SystemType  = weakupRecords[0].rmtype__c;  
         
      fRecColor = colorIndicator(integer.valueOf(weakupRecords[0].Frontal_F_REC_Ind__c));
      fDsaColor = colorIndicator(integer.valueOf(weakupRecords[0].Frontal_F_DSA_Ind__c));
      fDaColor  = colorIndicator(integer.valueOf(weakupRecords[0].Frontal_F_DA_Ind__c));
      lRecColor = colorIndicator(integer.valueOf(weakupRecords[0].Lateral_L_REC_Ind__c));
      lDsaColor = colorIndicator(integer.valueOf(weakupRecords[0].Lateral_L_DSA_Ind__c));
      lDaColor  = colorIndicator(integer.valueOf(weakupRecords[0].Lateral_L_DA_Ind__c));
    
      F_REC_kV   = colorIndicator(integer.valueOf(weakupRecords[0].f_f_rec_kv_ind__c));
      F_REC_mA   = colorIndicator(integer.valueOf(weakupRecords[0].f_f_rec_ma_ind__c));
      F_REC_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].f_f_rec_pix_ind__c));
      F_REC_msec = colorIndicator(integer.valueOf(weakupRecords[0].f_f_rec_msec_ind__c));
      F_REC_Dose = colorIndicator(integer.valueOf(weakupRecords[0].f_f_rec_dose_ind__c));
              
      F_DA_kV   = colorIndicator(integer.valueOf(weakupRecords[0].f_da_kv_ind__c));
      F_DA_mA   = colorIndicator(integer.valueOf(weakupRecords[0].f_da_ma_ind__c));
      F_DA_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].f_da_pix_ind__c));
      F_DA_msec = colorIndicator(integer.valueOf(weakupRecords[0].f_da_msec_ind__c));
      F_DA_Dose = colorIndicator(integer.valueOf(weakupRecords[0].f_da_dose_ind__c));

      F_DSA_kV   = colorIndicator(integer.valueOf(weakupRecords[0].f_dsa_kv_ind__c));
      F_DSA_mA   = colorIndicator(integer.valueOf(weakupRecords[0].f_dsa_ma_ind__c));
      F_DSA_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].f_dsa_pix_ind__c));
      F_DSA_msec = colorIndicator(integer.valueOf(weakupRecords[0].f_dsa_msec_ind__c));
      F_DSA_Dose = colorIndicator(integer.valueOf(weakupRecords[0].f_dsa_dose_ind__c));

      L_REC_kV   = colorIndicator(integer.valueOf(weakupRecords[0].l_f_rec_kv_ind__c));
      L_REC_mA   = colorIndicator(integer.valueOf(weakupRecords[0].l_f_rec_ma_ind__c));
      L_REC_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].l_f_rec_pix_ind__c));
      L_REC_msec = colorIndicator(integer.valueOf(weakupRecords[0].l_f_rec_msec_ind__c));
      L_REC_Dose = colorIndicator(integer.valueOf(weakupRecords[0].l_f_rec_dose_ind__c));
              
      L_DA_kV   = colorIndicator(integer.valueOf(weakupRecords[0].l_da_kv_ind__c));
      L_DA_mA   = colorIndicator(integer.valueOf(weakupRecords[0].l_da_ma_ind__c));
      L_DA_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].l_da_pix_ind__c));
      L_DA_msec = colorIndicator(integer.valueOf(weakupRecords[0].l_da_msec_ind__c));
      L_DA_Dose = colorIndicator(integer.valueOf(weakupRecords[0].l_da_dose_ind__c));

      L_DSA_kV   = colorIndicator(integer.valueOf(weakupRecords[0].l_dsa_kv_ind__c));
      L_DSA_mA   = colorIndicator(integer.valueOf(weakupRecords[0].l_dsa_ma_ind__c));
      L_DSA_Pix  = colorIndicator(integer.valueOf(weakupRecords[0].l_dsa_pix_ind__c));
      L_DSA_msec = colorIndicator(integer.valueOf(weakupRecords[0].l_dsa_msec_ind__c));
      L_DSA_Dose = colorIndicator(integer.valueOf(weakupRecords[0].l_dsa_dose_ind__c));
 
      F_REC_kV_Base  = 'REC_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_F_F_REC_kV__c)+' ';
      F_REC_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_F_REC_kV__c);
      F_REC_kV_Name  = F_REC_kV_Base + F_REC_kV_Value;
      F_REC_mA_Base  = 'REC_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_F_F_REC_mA__c)+' ';
      F_REC_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_F_REC_mA__c);
      F_REC_mA_Name  = F_REC_mA_Base + F_REC_mA_Value;
      F_REC_Pix_Base  = 'REC_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_F_F_REC_Pix__c)+' ';
      F_REC_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_F_REC_Pix__c);
      F_REC_Pix_Name  = F_REC_Pix_Base + F_REC_Pix_Value;
      F_REC_Msec_Base  = 'REC_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_F_F_REC_msec__c)+' ';
      F_REC_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_F_REC_msec__c);
      F_REC_Msec_Name  = F_REC_Msec_Base + F_REC_Msec_Value;
      F_REC_Dose_Base  = 'REC_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_F_F_REC_DOSE__c)+' ';
      F_REC_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_F_REC_DOSE__c);
      F_REC_Dose_Name  = F_REC_Dose_Base + F_REC_Dose_Value;

      F_DA_kV_Base  = 'DA_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DA_kV__c)+' ';
      F_DA_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DA_kV__c);
      F_DA_kV_Name  = F_DA_kV_Base + F_DA_kV_Value;
      F_DA_mA_Base  = 'DA_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DA_mA__c)+' ';
      F_DA_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DA_mA__c);
      F_DA_mA_Name  = F_DA_mA_Base + F_DA_mA_Value;
      F_DA_Pix_Base  = 'DA_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DA_Pix__c)+' ';
      F_DA_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DA_Pix__c);
      F_DA_Pix_Name  = F_DA_Pix_Base + F_DA_Pix_Value;
      F_DA_Msec_Base  = 'DA_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DA_msec__c)+' ';
      F_DA_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DA_msec__c);
      F_DA_Msec_Name  = F_DA_Msec_Base + F_DA_Msec_Value;
      F_DA_Dose_Base  = 'DA_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DA_DOSE__c)+' ';
      F_DA_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DA_DOSE__c);
      F_DA_Dose_Name  = F_DA_Dose_Base + F_DA_Dose_Value;
      
      F_DSA_kV_Base  = 'DSA_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DSA_kV__c)+' ';
      F_DSA_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DSA_kV__c);
      F_DSA_kV_Name  = F_DSA_kV_Base + F_DSA_kV_Value;
      F_DSA_mA_Base  = 'DSA_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DSA_mA__c)+' ';
      F_DSA_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DSA_mA__c);
      F_DSA_mA_Name  = F_DSA_mA_Base + F_DSA_mA_Value;
      F_DSA_Pix_Base  = 'DSA_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DSA_Pix__c)+' ';
      F_DSA_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DSA_Pix__c);
      F_DSA_Pix_Name  = F_DSA_Pix_Base + F_DSA_Pix_Value;
      F_DSA_Msec_Base  = 'DSA_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DSA_msec__c)+' ';
      F_DSA_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DSA_msec__c);
      F_DSA_Msec_Name  = F_DSA_Msec_Base + F_DSA_Msec_Value;
      F_DSA_Dose_Base  = 'DSA_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_F_DSA_DOSE__c)+' ';
      F_DSA_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].F_DSA_DOSE__c);
      F_DSA_Dose_Name  = F_DSA_Dose_Base + F_DSA_Dose_Value;      
      
 
      L_REC_kV_Base  = 'REC_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_L_F_REC_kV__c)+' ';
      L_REC_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_F_REC_kV__c);
      L_REC_kV_Name  = L_REC_kV_Base + L_REC_kV_Value;
      L_REC_mA_Base  = 'REC_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_L_F_REC_mA__c)+' ';
      L_REC_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_F_REC_mA__c);
      L_REC_mA_Name  = L_REC_mA_Base + L_REC_mA_Value;
      L_REC_Pix_Base  = 'REC_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_L_F_REC_Pix__c)+' ';
      L_REC_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_F_REC_Pix__c);
      L_REC_Pix_Name  = L_REC_Pix_Base + L_REC_Pix_Value;
      L_REC_Msec_Base  = 'REC_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_L_F_REC_msec__c)+' ';
      L_REC_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_F_REC_msec__c);
      L_REC_Msec_Name  = L_REC_Msec_Base + L_REC_Msec_Value;
      L_REC_Dose_Base  = 'REC_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_L_F_REC_DOSE__c)+' ';
      L_REC_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_F_REC_DOSE__c);
      L_REC_Dose_Name  = L_REC_Dose_Base + L_REC_Dose_Value;

      L_DA_kV_Base  = 'DA_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DA_kV__c)+' ';
      L_DA_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DA_kV__c);
      L_DA_kV_Name  = L_DA_kV_Base + L_DA_kV_Value;
      L_DA_mA_Base  = 'DA_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DA_mA__c)+' ';
      L_DA_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DA_mA__c);
      L_DA_mA_Name  = L_DA_mA_Base + L_DA_mA_Value;
      L_DA_Pix_Base  = 'DA_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DA_Pix__c)+' ';
      L_DA_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DA_Pix__c);
      L_DA_Pix_Name  = L_DA_Pix_Base + L_DA_Pix_Value;
      L_DA_Msec_Base  = 'DA_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DA_msec__c)+' ';
      L_DA_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DA_msec__c);
      L_DA_Msec_Name  = L_DA_Msec_Base + L_DA_Msec_Value;
      L_DA_Dose_Base  = 'DA_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DA_DOSE__c)+' ';
      L_DA_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DA_DOSE__c);
      L_DA_Dose_Name  = L_DA_Dose_Base + L_DA_Dose_Value;
      
      L_DSA_kV_Base  = 'DSA_kV :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DSA_kV__c)+' ';
      L_DSA_kV_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DSA_kV__c);
      L_DSA_kV_Name  = L_DSA_kV_Base + L_DSA_kV_Value;
      L_DSA_mA_Base  = 'DSA_mA :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DSA_mA__c)+' ';
      L_DSA_mA_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DSA_mA__c);
      L_DSA_mA_Name  = L_DSA_mA_Base + L_DSA_mA_Value;
      L_DSA_Pix_Base  = 'DSA_Pix :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DSA_Pix__c)+' ';
      L_DSA_Pix_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DSA_Pix__c);
      L_DSA_Pix_Name  = L_DSA_Pix_Base + L_DSA_Pix_Value;
      L_DSA_Msec_Base  = 'DSA_Msec :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DSA_msec__c)+' ';
      L_DSA_Msec_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DSA_msec__c);
      L_DSA_Msec_Name  = L_DSA_Msec_Base + L_DSA_Msec_Value;
      L_DSA_Dose_Base  = 'DSA_Dose :: Base: '+integer.valueOf(weakupRecords[0].Base_L_DSA_DOSE__c)+' ';
      L_DSA_Dose_Value = 'Value: '+ integer.valueOf(weakupRecords[0].L_DSA_DOSE__c);
      L_DSA_Dose_Name  = L_DSA_Dose_Base + L_DSA_Dose_Value;
    }            
    catch(Exception e)
    {
      System.debug(e.getMessage());
      Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
        'No Data/Invalid Data Available for VL Wakeup Check - Please create a Web Support Case via General Inquiry.'));
    }
  }  

}