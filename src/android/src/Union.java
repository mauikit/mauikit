package com.kde.maui.tools;

import android.provider.ContactsContract;
import android.content.Context;
import android.database.Cursor;
import android.app.Activity;
import android.content.ContentProviderOperation;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import java.util.ArrayList;
import android.accounts.AccountManager;
import android.accounts.Account;

public class Union
{

    public Union()
    {
    }
    
       public static void call(Activity context, String tel)
      {
			Intent callIntent = new Intent(Intent.ACTION_CALL);
                        callIntent.setData(Uri.parse("tel:"+tel));

                        context.startActivity(callIntent);
      }

//      public static void contacts()
//      {
//                        Intent contactPickerIntent = new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI);
//                        startActivityForResult(contactPickerIntent, CONTACT_PICKER_RESULT);
//      }

    public static String getContacts(Context c) 
    {
		//ActivityCompat.requestPermissions(this,new String[]{Manifest.permission.READ_CONTACTS},1);
		String fetch="<root>";

		Cursor phones = c.getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, null, null, null, null);

                while (phones.moveToNext())
                {
			String name = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
                        String phoneNumber = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                        String email = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS));
                        fetch += "<item><n>"+name+"</n><tel>"+phoneNumber+"</tel><email>"+email+"</email></item>";
		}

		fetch+="</root>";
		return fetch;
    }

    public static void addContact(Context c, String name, String tel, String tel2, String tel3, String email, String title, String org)
    {

        String DisplayName = name;
         String MobileNumber = tel;
         String HomeNumber = tel2;
         String WorkNumber = tel3;
         String emailID = email;
         String company = org;
         String jobTitle = title;

         ArrayList < ContentProviderOperation > ops = new ArrayList < ContentProviderOperation > ();

         ops.add(ContentProviderOperation.newInsert(
         ContactsContract.RawContacts.CONTENT_URI)
             .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, null)
             .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, null)
             .build());

         //------------------------------------------------------ Names
         if (DisplayName != null)
         {
             ops.add(ContentProviderOperation.newInsert(
             ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                 .withValue(
             ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
             DisplayName).build());
         }

         //------------------------------------------------------ Mobile Number
         if (MobileNumber != null)
         {
             ops.add(ContentProviderOperation.
             newInsert(ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                 .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, MobileNumber)
                 .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,
             ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)
                 .build());
         }

         //------------------------------------------------------ Home Numbers
         if (HomeNumber != null)
         {
             ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                 .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, HomeNumber)
                 .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,
             ContactsContract.CommonDataKinds.Phone.TYPE_HOME)
                 .build());
         }

         //------------------------------------------------------ Work Numbers
         if (WorkNumber != null) {
             ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE)
                 .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, WorkNumber)
                 .withValue(ContactsContract.CommonDataKinds.Phone.TYPE,
             ContactsContract.CommonDataKinds.Phone.TYPE_WORK)
                 .build());
         }

         //------------------------------------------------------ Email
         if (emailID != null) {
             ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE)
                 .withValue(ContactsContract.CommonDataKinds.Email.DATA, emailID)
                 .withValue(ContactsContract.CommonDataKinds.Email.TYPE, ContactsContract.CommonDataKinds.Email.TYPE_WORK)
                 .build());
         }

         //------------------------------------------------------ Organization
         if (!company.equals("") && !jobTitle.equals("")) {
             ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                 .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                 .withValue(ContactsContract.Data.MIMETYPE,
             ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE)
                 .withValue(ContactsContract.CommonDataKinds.Organization.COMPANY, company)
                 .withValue(ContactsContract.CommonDataKinds.Organization.TYPE, ContactsContract.CommonDataKinds.Organization.TYPE_WORK)
                 .withValue(ContactsContract.CommonDataKinds.Organization.TITLE, jobTitle)
                 .withValue(ContactsContract.CommonDataKinds.Organization.TYPE, ContactsContract.CommonDataKinds.Organization.TYPE_WORK)
                 .build());
         }

         // Asking the Contact provider to create a new contact
         try {
             c.getContentResolver().applyBatch(ContactsContract.AUTHORITY, ops);
         } catch (Exception e) {
             e.printStackTrace();
//             Toast.makeText(myContext, "Exception: " + e.getMessage(), Toast.LENGTH_SHORT).show();
         }
     }

 public static String getAccounts(Context c)
 {
     Account[] accountList = AccountManager.get(c).getAccounts();

     String accountSelection = "<root>";

     for(int i = 0 ; i < accountList.length ; i++)
     {
        String accountName = accountList[i].name;
        String accountType =  accountList[i].type;

       accountSelection += "<account><name>"+accountName+"</name><type>"+accountType+"</type></account>";

     }

 accountSelection += "</root>";
    return accountSelection;
  }
 }
