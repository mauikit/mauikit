package com.kde.maui.tools;

import android.provider.ContactsContract;
import android.content.Context;
import android.database.Cursor;
import android.app.Activity;

import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;

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

		while (phones.moveToNext()) {
			String name = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
                        String phoneNumber = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                        String email = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS));
                        fetch += "<item><n>"+name+"</n><tel>"+phoneNumber+"</tel><email>"+email+"</email></item>";
		}
		fetch+="</root>";
		return fetch;
    }
}
