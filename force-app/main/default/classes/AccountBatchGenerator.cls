global class AccountBatchGenerator implements Database.Batchable<Integer> {
    global Integer totalAccounts; // Total number of accounts to create
    global Integer batchSize;     // Maximum number of accounts to insert per batch

    // Constructor to initialize total count and batch size
    public AccountBatchGenerator(Integer totalAccounts, Integer batchSize) {
        this.totalAccounts = totalAccounts;
        this.batchSize = Math.min(batchSize, 10000); // Ensure no more than 10,000 per execution
    }

    // Start method to provide an iterable of integers representing the total accounts in batches
    global Iterable<Integer> start(Database.BatchableContext BC) {
        Integer totalBatches = (totalAccounts + batchSize - 1) / batchSize;
        List<Integer> batchList = new List<Integer>();
        for (Integer i = 0; i < totalBatches; i++) {
            batchList.add(i);
        }
        return batchList;
    }

    // Execute method to create each batch of accounts, limited to 10,000 records
    global void execute(Database.BatchableContext BC, List<Integer> scope) {
        List<Account> accounts = new List<Account>();
        Integer startAccountNum = scope[0] * batchSize + 1;

        // Add accounts within the allowed batch size range
        for (Integer i = 0; i < batchSize && startAccountNum + i <= totalAccounts; i++) {
            Integer accountNumber = startAccountNum + i;
            
            // Create Account record
            accounts.add(new Account(
                Name = 'Account ' + accountNumber,
                Industry = 'Technology', // Example value
                AnnualRevenue = 1000000 + (accountNumber * 1000) // Adjusted for variability
                // Add other fields as needed
            ));
        }

        // Insert accounts if list is not empty
        if (!accounts.isEmpty()) {
            insert accounts;
        }
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job for creating accounts has completed.');
    }
}