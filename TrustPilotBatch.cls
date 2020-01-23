global class TrustPilotBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, ContactHub_ID__c, Email__c, Full_Name__c, TrustPilot_Link__c FROM TrustPilot_Links__c';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<TrustPilot_Links__c> scope) {
      string encryptkeyy = '3kXLV1rnimLR4324TPGz7iu2Wdd+/hYVTB/Dt6nnIk=';  // this key can be called from custom settings record for security reasons
      string authkeyy =    '2BKulGe3CTWOdfsdskM62dNpFAeuuWhfevc4A='; // this key can be called from custom settings record for security reasons
   //  public string domain = 'Hanover.com';
         for(TrustPilot_Links__c tr : scope)
         {
         
        // list<TrustPilot_Links__c> tr = new list<TrustPilot_Links__c>(); 
          //  tr = [SELECT Id, ContactHub_ID__c, Email__c, Full_Name__c, TrustPilot_Link__c FROM TrustPilot_Links__c LIMIT 1];
            
            JSONGenerator gen = JSON.createGenerator(true);
             gen.writeStartObject(); 
             
             gen.writeFieldName('email');
            gen.writeObject(tr.Email__c);
            
            gen.writeFieldName('name');
            gen.writeObject(tr.Full_Name__c); 
            
            gen.writeFieldName('ref');
            gen.writeObject(tr.ContactHub_ID__c);
            
            gen.writeEndObject();
            
            system.debug(gen.getAsString());
            
            string order   = gen.getAsString();
            
              
   //  encryptkeybase64  = EncodingUtil.base64Decode(encryptkeyy, 'UTF-8');
    
    Blob encKey = EncodingUtil.base64Decode(encryptkeyy);
    system.debug('enckey**' +encKey);

    
    
     Blob authKey = EncodingUtil.base64Decode(authkeyy);
     system.debug('authenticationKey**' +authKey);
    
    Blob data = Blob.valueOf(order);
    
 //   Blob s =  Blob.valueOf(Crypto.getRandomInteger());

    
    //Initializzation vector
      Blob encryptedBlob = Crypto.encryptWithManagedIV('AES256',encKey,data);
      system.debug('encryptedBlob **' +encryptedBlob );
      
   //   Blob cipherText = Crypto.encryptWithManagedIV('AES256', authKey, Blob.valueOf(clearText));
      String encodedCipherText = EncodingUtil.base64Encode(encryptedBlob);  // all good until here .. next is to generate hmac cipher
      system.debug('encodedCipherText **' +encodedCipherText );
      
       string payload = EncodingUtil.urlEncode(encodedCipherText,'UTF-8');
        system.debug('payload **' +payload );
        
        string link =  'https://www.trustpilot.com/evaluate-bgl/hanover.com?p='+payload;
        system.debug(link);
   //  String encodedCipherText = EncodingUtil.base64Encode(cipherText);
     
  //   string encryptedText = EncodingUtil.base64Encode(encryptedBlob);
    Blob data1 = crypto.generateMac('HmacSHA256',encryptedBlob,authKey ); 
    system.debug('data1** '+data1 );
    
    
    String anotherone = EncodingUtil.base64Encode(data1);
    system.debug('anotherone ** '+anotherone );
  //  String s1 = encodedCipherText+anotherone;
      String s1 = EncodingUtil.convertToHex(encryptedBlob) + EncodingUtil.convertToHex(data1);
      Blob bb = EncodingUtil.convertFromHex(s1);
      string finaltime = EncodingUtil.base64Encode(bb);
      
       string payload1 = EncodingUtil.urlEncode(finaltime ,'UTF-8');
                        
    
                      
    tr.TrustPilot_Link__c = 'https://www.trustpilot.com/evaluate-bgl/hanover.com?p='+payload1;
            
            
                     
         }
         update scope;
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
}