public virtual class SortController 
{

    public List<Opportunity> Opps {set;get;}
        
    private String sortExp = 'Name';
    public String Query {set;get;}          

    private String sortDirection = 'ASC';
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            
            sortExp = value;
        }
    }

    public String getSortDirection()
    {   
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }

    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }   

}