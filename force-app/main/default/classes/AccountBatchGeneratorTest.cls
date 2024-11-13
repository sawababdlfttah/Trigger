@isTest
private class AccountBatchGeneratorTest {
    @isTest
    static void testSingleBatch() {
        // Test creating accounts that fit in a single batch
        Integer totalAccounts = 5;
        Integer batchSize = 10;
        
        Test.startTest();
        AccountBatchGenerator batchJob = new AccountBatchGenerator(totalAccounts, batchSize);
        Database.executeBatch(batchJob, batchSize);
        Test.stopTest();
        
        // Verify results
        List<Account> createdAccounts = [SELECT Id, Name, Industry, AnnualRevenue 
                                       FROM Account 
                                       ORDER BY Name ASC];
        
        
        // Verify account details
        for (Integer i = 0; i < totalAccounts; i++) {
            Account acc = createdAccounts[i];
            System.assertEquals('Account ' + (i + 1), acc.Name, 
                'Account name should match the expected pattern');
            System.assertEquals('Technology', acc.Industry, 
                'Industry should be set to Technology');
            System.assertEquals(1000000 + ((i + 1) * 1000), acc.AnnualRevenue, 
                'AnnualRevenue should match the expected calculation');
        }
    }
    
    @isTest
    static void testMultipleBatches() {
        // Test creating accounts that span multiple batches
        Integer totalAccounts = 15;
        Integer batchSize = 6;
        
        Test.startTest();
        AccountBatchGenerator batchJob = new AccountBatchGenerator(totalAccounts, batchSize);
        Database.executeBatch(batchJob, batchSize);
        Test.stopTest();
        
        // Verify results
        List<Account> createdAccounts = [SELECT Id, Name 
                                       FROM Account 
                                       ORDER BY Name ASC];
        
    }
    
    @isTest
    static void testBatchSizeLimitation() {
        // Test that batch size is limited to 10000
        Integer totalAccounts = 5;
        Integer oversizedBatch = 15000;
        
        AccountBatchGenerator batchJob = new AccountBatchGenerator(totalAccounts, oversizedBatch);
        
        Test.startTest();
        // Get the batches using the start method
        List<Integer> batches = (List<Integer>)batchJob.start(null);
        Test.stopTest();
        
        // Verify that the batch size was limited to 10000
        System.assertEquals(10000, batchJob.batchSize, 
            'Batch size should be limited to 10000');
        
        // Verify number of batches
        System.assertEquals(1, batches.size(), 
            'Should only create one batch for 5 accounts');
    }
    
    @isTest
    static void testZeroAccounts() {
        // Test handling of zero accounts
        Integer totalAccounts = 0;
        Integer batchSize = 10;
        
        Test.startTest();
        AccountBatchGenerator batchJob = new AccountBatchGenerator(totalAccounts, batchSize);
        Database.executeBatch(batchJob, batchSize);
        Test.stopTest();
        
        // Verify no accounts were created
        List<Account> createdAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, createdAccounts.size(), 
            'No accounts should be created when totalAccounts is 0');
    }
    
    @isTest
    static void testBatchCalculation() {
        // Test the batch calculation logic
        Integer totalAccounts = 25;
        Integer batchSize = 10;
        
        AccountBatchGenerator batchJob = new AccountBatchGenerator(totalAccounts, batchSize);
        
        Test.startTest();
        List<Integer> batches = (List<Integer>)batchJob.start(null);
        Test.stopTest();
        
        // Should create 3 batches: 0-9, 10-19, 20-24
        Integer expectedBatches = (totalAccounts + batchSize - 1) / batchSize;
        System.assertEquals(expectedBatches, batches.size(), 
            'Number of batches should match calculation');
    }
}