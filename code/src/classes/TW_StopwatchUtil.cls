/**
* @author Amitkumar Joshi
* @date 06/18/2017
*
* @description This is utility class for Timer Component. It contains the utility methods to calculate the invoice amount,
* convert milliseconds to hours and  get first 3 letters of month.
*
*/
public class TW_StopwatchUtil {
    
    /**
    * @description calculate invoice amount (timespent * hourlyRate)
    * 
    * @param Double timeSpent  total timespent on the task
    * @paramDouble hourlyRate  hourly rate of project member.
    * @return Double  invoice amount
    */
    public static Double calculateInvoicedAmount(Double timeSpent, Double hourlyRate){
        System.debug('TW_StopwatchUtil, calculateInvoicedAmount(), start, timeSpent=' + timeSpent +',hourlyRate=' + hourlyRate);
        return TW_StopwatchUtil.convertMillsToHours(timeSpent) * hourlyRate;
        
    }
    
   /**
    * @description convert milliseconds to hours.
    * 
    * @param Double timeSpent  total timespent on the task
    * @return Decimal  time in hours
    */
    public static Decimal convertMillsToHours(Double timeSpent){
        System.debug('TW_StopwatchUtil, convertMillsToHours(), start, timeSpent=' + timeSpent);
        
        Decimal hours =  (((timeSpent / 60) / 60) / 1000);
        hours = hours.setScale(2);
        System.debug('convertMillsToHours, hours=' + hours);
        
        System.debug('TW_StopwatchUtil, convertMillsToHours(), end, hours=' + hours);
        
        return hours;
    }
    
    /**
    * @description convert milliseconds to hours.
    * 
    * @param Integer month  Month of the year.
    * @return String  First three chars of month.
    */
    public static String  getTextMonthFirst3Chars(Integer month){
        System.debug('TW_StopwatchUtil, getTextMonthFirst3Chars(), start, month=' + month);
       
        String textMonth = getTextMonth(month);
        
         System.debug('TW_StopwatchUtil, getTextMonthFirst3Chars(), end, month=' + textMonth.substring(0,3));
        return textMonth.substring(0,3);
    }
    
     /**
    * @description get text month value from integer value. e.g.  3 = 'March'
    * 
    * @param Integer month  Month of the year.
    * @return String  Text month value.
    */
    public static String  getTextMonth(Integer month){
        Map<Integer, String> monthMap = new Map<Integer, String>{1=>'January',2=> 'February',3=> 'March', 4=> 'April', 5=> 'May', 6=> 'June',7=> 'July',8=> 'August',9=> 'September',10=>'October',11=> '1November',12=> 'December'};
       return monthMap.get(month);
    }
}