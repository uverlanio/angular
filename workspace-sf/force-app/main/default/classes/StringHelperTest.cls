@isTest
private class StringHelperTest {
@isTest static void testStringLength() {
        string oldString = '123';       
        string newString = StringHelper.FormatNumeroSorte(oldString);
        System.assertEquals(7, newString.length());
    }
}