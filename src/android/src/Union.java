package com.kde.maui.tools;

import android.provider.ContactsContract;
import android.database.Cursor;
import android.app.Activity;
import android.os.Build;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import android.accounts.AccountManager;
import android.accounts.Account;
import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.ContentProviderOperation;
import android.content.ContentProviderOperation.Builder;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.Context;
import android.provider.CallLog.Calls;
import android.provider.CallLog;

public class Union
{
    enum KEY
    {
        N,
        TEL,
        TEL2,
        TEL3,
        EMAIL,
        EMAIL2,
        EMAIL3,
        PHOTO,
        ORG,
        TITLE,
        NICK
    }

    public Union() {}

    public static void call(Activity context, String tel)
    {
//        Intent callIntent = new Intent(Intent.ACTION_CALL);
//        callIntent.setData(Uri.parse("tel:" + tel));

//        context.startActivity(callIntent);



        Intent callIntent = new Intent(Intent.ACTION_CALL);
//        callIntent.setPackage("com.android.phone");          // force native dialer  (Android < 5)
        callIntent.setPackage("com.android.server.telecom"); // force native dialer  (Android >= 5)
        callIntent.setData(Uri.parse("tel:" + tel));
        callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(callIntent);
    }

//      public static void contacts()
//      {
//                        Intent contactPickerIntent = new Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI);
//                        startActivityForResult(contactPickerIntent, CONTACT_PICKER_RESULT);
//      }


    public static HashMap<String, String> getContact(Context c, String id)
    {
        HashMap<String, String> res = new HashMap<String, String>();

        String email = "", org = "", title = "";

        ContentResolver cr = c.getContentResolver();

        //ADD E-MAIL DATA...
        Cursor emailCursor = cr.query(ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                null, ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                new String[]{id},
                null);

        if (emailCursor != null)
            if (emailCursor.moveToFirst())
                email = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA));


        if (emailCursor != null)
            emailCursor.close();

        //ADD ORG DATA...
        Cursor orgCur = cr.query(ContactsContract.Data.CONTENT_URI,
                null, ContactsContract.Data.CONTACT_ID + " = ?",
                new String[]{id},
                null);

        if (orgCur != null)
            if (orgCur.moveToFirst())
            {
                org = orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.DATA)) == null ? "" : orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.DATA));
                title = orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.TITLE)) == null ? "" : orgCur.getString(orgCur.getColumnIndex(ContactsContract.CommonDataKinds.Organization.TITLE));
            }

//                    //ADD ADDRESS DATA...
//                    Cursor addrCursor = c.getContentResolver().query(ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_URI,
//                            null, ContactsContract.CommonDataKinds.StructuredPostal.CONTACT_ID + " = ?",
//                            new String[]{id},
//                            null);

//                    if (addrCursor != null)
//                    {
//                        int i = 0;

//                        while (addrCursor.moveToNext())
//                        {
//                            if (i > 2) break;

//                            String city = addrCursor.getString(addrCursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.CITY));
//                            String state = addrCursor.getString(addrCursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.REGION));
//                            String country = addrCursor.getString(addrCursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY));

//                            if (i == 0)
//                                fetch += "<adr><city>" + city + "</city><state>" + state + "</state><country>" + country + "</country></adr>";
//                            else
//                                fetch += "<adr" + Integer.toString(i) + "><city>" + city + "</city><state>" + state + "</state><country>" + country + "</country></adr>";

//                            i++;
//                        }
//                    }

//                    if (addrCursor != null)
//                        addrCursor.close();

        //Get Instant Messenger.........
//                    String imWhere = ContactsContract.Data.CONTACT_ID + " = ? AND " + ContactsContract.Data.MIMETYPE + " = ?";
//                    String[] imWhereParams = new String[]{id, ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE};
//                    Cursor imCur = cr.query(ContactsContract.Data.CONTENT_URI, null, imWhere, imWhereParams, null);

//                    if (imCur.moveToFirst())
//                    {
//                        String imName = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.DATA));
//                        String imType;
//                        imType = imCur.getString(imCur.getColumnIndex(ContactsContract.CommonDataKinds.Im.TYPE));

//                        fetch += "<im><nickname>" + imName + "</nickname><type>" + imType + "</type></im>";

//                    }

//                if (imCur != null)
//                    imCur.close();


        res.put("email", email == null ? "" : email);
        res.put("org", org == null ? "" : org);
        res.put("title", title == null ? "" : title);

        return res;
    }

    public static Bitmap loadContactPhoto(Context c, String id)
    {
        System.out.println("GETTIGN CONTACT IMAGE " + id);
        ContentResolver cr = c.getContentResolver();
        Uri uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, Long.parseLong(id));
        InputStream input = ContactsContract.Contacts.openContactPhotoInputStream(cr, uri);
        if (input == null) {
            System.out.println("GETTIGN CONTACT IMAGE: NO IMAGE");

            return null;
        }

        System.out.println("GETTIGN CONTACT IMAGE: GOT IMAGE");

        return BitmapFactory.decodeStream(input);
    }


//    private static String[] convertColumns(String columns)
//    {
////        String[] res = new String[];

////        final HashMap<String, int> map = new HashMap<String, int>();
////        map.put("fav",  ContactsContract.Contacts.STARRED);
////        map.put("fav",  ContactsContract.Contacts.STARRED);
////        map.put("fav",  ContactsContract.Contacts.STARRED);

////        for(String value : columns.split(","))
////        {

////            }

////        return res;

//        }

    private static List<Integer> getRawContactsIdList(Context c)
    {
        List<Integer> ret = new ArrayList<Integer>();

              ContentResolver contentResolver = c.getContentResolver();

              // Row contacts content uri( access raw_contacts table. ).
//              Uri rawContactUri = ContactsContract.RawContacts.CONTENT_URI;
              Uri rawContactUri = ContactsContract.Contacts.CONTENT_URI;
              // Return _id column in contacts raw_contacts table.
              final String queryColumnArr[] = {ContactsContract.Contacts._ID};
              // Query raw_contacts table and return raw_contacts table _id.
//              final String RAW_CONTACT_SELECTION = ContactsContract.RawContacts.DELETED + " = 0 ";

              Cursor cursor = contentResolver.query(rawContactUri,queryColumnArr, null, null, null);
              if(cursor!=null)
              {
                  cursor.moveToFirst();
                  do{
                      int idColumnIndex = cursor.getColumnIndex(ContactsContract.Contacts._ID);
                      int rawContactsId = cursor.getInt(idColumnIndex);
                      ret.add(new Integer(rawContactsId));
                  }while(cursor.moveToNext());
              }

              cursor.close();

              return ret;
    }

    public static List<HashMap<String, String>> fetchContacts(Context c)
    {
        System.out.println("FETCHING CONTACTS");
        List<HashMap<String,String>> res =  new ArrayList<HashMap<String, String>>();



        ContentResolver cr = c.getContentResolver();

            final String[] projection = new String[]
            {
                ContactsContract.Contacts._ID,
                    ContactsContract.Contacts.DISPLAY_NAME,
                    ContactsContract.Contacts.STARRED,
                    ContactsContract.Contacts.PHOTO_URI
            };

        Cursor mainCursor = cr.query(ContactsContract.Contacts.CONTENT_URI, projection, null, null, null);
        if (mainCursor != null)
               {
                   while (mainCursor.moveToNext())
                   {
    String tel = "", accountName = "" , accountType= "";
                       String id = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts._ID));
                       String fav = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.STARRED));
                       String name = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
  String photo = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.PHOTO_URI));


                            //ADD ACCOUNT DATA...

                            final String[] accountProjection = new String[] {
                                    ContactsContract.RawContacts.ACCOUNT_NAME,
                                    ContactsContract.RawContacts.ACCOUNT_TYPE
                            };
                            Cursor accountCursor = cr.query(ContactsContract.RawContacts.CONTENT_URI,
                                    accountProjection,
                                    ContactsContract.RawContacts.CONTACT_ID + " = ?",
                                    new String[]{id},
                                    null);

                            if (accountCursor != null)
                                if (accountCursor.moveToFirst())
                                {
                                    accountName = accountCursor.getString(accountCursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME));
                                    accountType = accountCursor.getString(accountCursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE));
                                }


                            if (accountCursor != null)
                                accountCursor.close();

       Cursor phoneCursor = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
       new String[] {ContactsContract.CommonDataKinds.Phone.NUMBER},
                       ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                       new String[]{id},
                       null);

               if (phoneCursor != null)
                   if (phoneCursor.moveToFirst())
                       tel = phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));


               if (phoneCursor != null)
                   phoneCursor.close();



                       HashMap<String, String> contact = new HashMap<String, String>();
                       contact.put("id", id);
                       contact.put("fav", fav == null ? "" : fav);
                       contact.put("tel", tel == null ? "" : tel);
       //                contact.put("email", email == null ? "" : email);
                       contact.put("n", name == null ? "" : name);
                       contact.put("account", accountName == null ? "" : accountName);
                       contact.put("type", accountType == null ? "" : accountType);
                       contact.put("photo", photo == null ? "" : photo);
       res.add(contact);

                       }

                   }

                           if (mainCursor != null)
                               mainCursor.close();


//final String[] projection = new String[] {
//    ContactsContract.Data.CONTACT_ID,
//        ContactsContract.Data.MIMETYPE,
//        ContactsContract.Contacts.DISPLAY_NAME,
//        ContactsContract.Contacts.STARRED,
//        ContactsContract.Contacts.PHOTO_URI,
//        ContactsContract.CommonDataKinds.Phone.NUMBER,
//        ContactsContract.RawContacts.ACCOUNT_NAME,
//        ContactsContract.RawContacts.ACCOUNT_TYPE,
//        ContactsContract.CommonDataKinds.Email.ADDRESS
//};

//        List<Integer> rawContactsIdList = getRawContactsIdList(c);
//        final int contactListSize = rawContactsIdList.size();
//        System.out.println("ACCOUNTS LIST SIZE:" + contactListSize);
//        for(int i=0;i<contactListSize;i++)
//        {
//            // Get the raw contact id.
//            Integer rawContactId = rawContactsIdList.get(i);
//            final StringBuffer whereClauseBuf = new StringBuffer();
//            whereClauseBuf.append(ContactsContract.Data.CONTACT_ID);
//            whereClauseBuf.append("=");
//            whereClauseBuf.append(rawContactId);

//            Cursor mainCursor = cr.query(ContactsContract.Data.CONTENT_URI, projection, whereClauseBuf.toString(), null, null);

//            if(mainCursor!=null && mainCursor.getCount() > 0)
//            {

//                mainCursor.moveToFirst();
//                long contactId = mainCursor.getLong(mainCursor.getColumnIndex(ContactsContract.Data.CONTACT_ID));
//                String fav = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.STARRED));
////                String name = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
//                String accountName = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME));
//                String accountType = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE));
////                String tel = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
////                String email = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS));
////                String photo = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.PHOTO_URI));

//                HashMap<String, String> contact = new HashMap<String, String>();
//                contact.put("id", Long.toString(contactId));
//                contact.put("fav", fav == null ? "" : fav);
////                contact.put("tel", tel == null ? "" : tel);
////                contact.put("email", email == null ? "" : email);
////                contact.put("n", name == null ? "" : name);
//                contact.put("account", accountName == null ? "" : accountName);
//                contact.put("type", accountType == null ? "" : accountType);
////                contact.put("photo", photo == null ? "" : photo);

//                            do
//                            {
//                                // First get mimetype column value.
//                                String mimeType = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Data.MIMETYPE));

//                                contact.putAll(getColumnValueByMimetype(mainCursor, mimeType));


//                            }while(mainCursor.moveToNext());

//                res.add(contact);

//            }

//            if (mainCursor != null)
//                mainCursor.close();

//        }
        return res;
    }

    /*
     *  Get email type related string format value.
     * */
    private static String getEmailTypeString(int dataType)
    {
        String ret = "";

        if(ContactsContract.CommonDataKinds.Email.TYPE_HOME == dataType)
        {
            ret = "Home";
        }else if(ContactsContract.CommonDataKinds.Email.TYPE_WORK==dataType)
        {
            ret = "Work";
        }
        return ret;
    }

    /*
     *  Get phone type related string format value.
     * */
    private static String getPhoneTypeString(int dataType)
    {
        String ret = "";

        if(ContactsContract.CommonDataKinds.Phone.TYPE_HOME == dataType)
        {
            ret = "Home";
        }else if(ContactsContract.CommonDataKinds.Phone.TYPE_WORK==dataType)
        {
            ret = "Work";
        }else if(ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE==dataType)
        {
            ret = "Mobile";
        }
        return ret;
    }


    private static HashMap<String, String> getColumnValueByMimetype(Cursor cursor, String mimeType)
    {
        HashMap<String, String> res = new HashMap<String, String>();

        switch (mimeType)
        {
            // Get email data.
//            case ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE :
//                // Email.ADDRESS == data1
//                String emailAddress = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS));
//                // Email.TYPE == data2
//                int emailType = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE));
//                String emailTypeStr = getEmailTypeString(emailType);

//                res.put("email", emailAddress);
//                res.put("email_type", Integer.toString(emailType));
//                res.put("email_str_type", emailTypeStr);
//                break;

            // Get im data.
//            case ContactsContract.CommonDataKinds.Im.CONTENT_ITEM_TYPE:
//                // Im.PROTOCOL == data5
//                String imProtocol = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Im.PROTOCOL));
//                // Im.DATA == data1
//                String imId = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Im.DATA));

//                res.put("im", imProtocol);
//                res.put("im_id", imId);
//                break;

            // Get nickname
//            case ContactsContract.CommonDataKinds.Nickname.CONTENT_ITEM_TYPE:
//                // Nickname.NAME == data1
//                String nickName = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Nickname.NAME));
//                res.put("nickname", nickName);
//                break;

//            // Get organization data.
//            case ContactsContract.CommonDataKinds.Organization.CONTENT_ITEM_TYPE:
//                // Organization.COMPANY == data1
//                String company = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Organization.COMPANY));
//                // Organization.DEPARTMENT == data5
//                String department = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Organization.DEPARTMENT));
//                // Organization.TITLE == data4
//                String title = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Organization.TITLE));
//                // Organization.JOB_DESCRIPTION == data6
//                String jobDescription = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Organization.JOB_DESCRIPTION));
//                // Organization.OFFICE_LOCATION == data9
//                String officeLocation = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Organization.OFFICE_LOCATION));

//                res.put("org", company);
//                res.put("department", department);
//                res.put("title", title);
//                res.put("job_description", jobDescription);
//                res.put("office_location", officeLocation);
//                break;

            // Get phone number.
            case ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE:
                // Phone.NUMBER == data1
                String phoneNumber = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
                // Phone.TYPE == data2
//                int phoneTypeInt = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE));
//                String phoneTypeStr = getPhoneTypeString(phoneTypeInt);

                res.put("tel", phoneNumber);/*
                res.put("tel_type", Integer.toString(phoneTypeInt));
                res.put("tel_str_type", phoneTypeStr);*/
                break;

            // Get sip address.
//            case ContactsContract.CommonDataKinds.SipAddress.CONTENT_ITEM_TYPE:
//                // SipAddress.SIP_ADDRESS == data1
//                String address = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.SipAddress.SIP_ADDRESS));
//                // SipAddress.TYPE == data2
//                int addressTypeInt = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.SipAddress.TYPE));
//                String addressTypeStr = getEmailTypeString(addressTypeInt);

//                res.put("address", address);
//                res.put("address_type", Integer.toString(addressTypeInt));
//                res.put("address_str_type", addressTypeStr);
//                break;

//            // Get display name.
            case ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE:
                // StructuredName.DISPLAY_NAME == data1
                String displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
//                // StructuredName.GIVEN_NAME == data2
//                String givenName = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME));
//                // StructuredName.FAMILY_NAME == data3
//                String familyName = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME));

                res.put("n", displayName);/*
                res.put("name", givenName);
                res.put("lastname", familyName);*/
                break;

//            // Get postal address.
//            case ContactsContract.CommonDataKinds.StructuredPostal.CONTENT_ITEM_TYPE:
//                // StructuredPostal.COUNTRY == data10
//                String country = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.COUNTRY));
//                // StructuredPostal.CITY == data7
//                String city = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.CITY));
//                // StructuredPostal.REGION == data8
//                String region = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.REGION));
//                // StructuredPostal.STREET == data4
//                String street = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.STREET));
//                // StructuredPostal.POSTCODE == data9
//                String postcode = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.POSTCODE));
//                // StructuredPostal.TYPE == data2
//                int postType = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.StructuredPostal.TYPE));
//                String postTypeStr = getEmailTypeString(postType);

//                res.put("country", country);
//                res.put("city", city);
//                res.put("region", region);
//                res.put("street", street);
//                res.put("postcode", postcode);
//                res.put("postcode_type", Integer.toString(postType));
//                res.put("postcode_str_type", postTypeStr);
//                break;

//            // Get identity.
//            case ContactsContract.CommonDataKinds.Identity.CONTENT_ITEM_TYPE:
//                // Identity.IDENTITY == data1
//                String identity = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Identity.IDENTITY));
//                // Identity.NAMESPACE == data2
//                String namespace = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Identity.NAMESPACE));

//                res.put("identity", identity);
//                res.put("identity_namespace", namespace);
//                break;

            // Get photo.
            case ContactsContract.CommonDataKinds.Photo.CONTENT_ITEM_TYPE:
                // Photo.PHOTO == data15
                String photo = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.PHOTO_URI));
                // Photo.PHOTO_FILE_ID == data14
//                String photoFileId = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Photo.PHOTO_FILE_ID));

                res.put("photo", photo);
//                res.put("photo_file_id", photoFileId);
                break;

//            // Get group membership.
//            case ContactsContract.CommonDataKinds.GroupMembership.CONTENT_ITEM_TYPE:
//                // GroupMembership.GROUP_ROW_ID == data1
//                int groupId = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.GroupMembership.GROUP_ROW_ID));
//                res.put("group", Integer.toString(groupId));
//                break;

//            // Get website.
//            case ContactsContract.CommonDataKinds.Website.CONTENT_ITEM_TYPE:
//                // Website.URL == data1
//                String websiteUrl = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Website.URL));
//                // Website.TYPE == data2
//                int websiteTypeInt = cursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Website.TYPE));
//                String websiteTypeStr = getEmailTypeString(websiteTypeInt);

//                res.put("url", websiteUrl);
//                res.put("url_type", Integer.toString(websiteTypeInt));
//                res.put("url_str_type", websiteTypeStr);
//                break;

//            // Get note.
//            case ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE:
//                // Note.NOTE == data1
//                String note = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Note.NOTE));
//                res.put("note", note);
//                break;

        }

        return res;
    }

    public static int APIVersion()
    {
        return Build.VERSION.SDK_INT;

    }



    public static void addContact(Context c,
                                  String name,
                                  String tel,
                                  String tel2,
                                  String tel3,
                                  String email,
                                  String title,
                                  String org,
                                  String photoUrl,
                                  String accountName,
                                  String accountType)
    {

        String DisplayName = name;
        String MobileNumber = tel;
        String HomeNumber = tel2;
        String WorkNumber = tel3;
        String emailID = email;
        String company = org;
        String jobTitle = title;
        String photo = photoUrl;

        ArrayList<ContentProviderOperation> ops = new ArrayList<ContentProviderOperation>();

        ops.add(ContentProviderOperation.newInsert(
                ContactsContract.RawContacts.CONTENT_URI)
                .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, accountType)
                .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, accountName)
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

        //------------------------------------------------------ Photo
        if (photo != null)
        {
            ops.add(ContentProviderOperation.newInsert(
                    ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE,
                            ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE)
                    .withValue(
                            ContactsContract.CommonDataKinds.Photo.PHOTO,
                            photo).build());
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
        if (WorkNumber != null)
        {
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
        if (emailID != null)
        {
            ops.add(ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                    .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                    .withValue(ContactsContract.Data.MIMETYPE,
                            ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE)
                    .withValue(ContactsContract.CommonDataKinds.Email.DATA, emailID)
                    .withValue(ContactsContract.CommonDataKinds.Email.TYPE, ContactsContract.CommonDataKinds.Email.TYPE_WORK)
                    .build());
        }

        //------------------------------------------------------ Organization
        if (!company.equals("") && !jobTitle.equals(""))
        {
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
        try
        {
            c.getContentResolver().applyBatch(ContactsContract.AUTHORITY, ops);
        } catch (Exception e)
        {
            e.printStackTrace();
//             Toast.makeText(myContext, "Exception: " + e.getMessage(), Toast.LENGTH_SHORT).show();
        }
    }

    public static void updateContact(Context c, String id, String field, String value)
    {

        ContentResolver cr = c.getContentResolver();

        String firstname = "Contact's first name";
        String lastname = "Last name";
        String number = "000 000 000";

        ArrayList<ContentProviderOperation> ops = new ArrayList<ContentProviderOperation>();

        Builder builder;
        switch(field)
        {

            case "tel" :
            {
                // Number
                builder = ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI);
                builder.withSelection(ContactsContract.Data.CONTACT_ID + "=?" + " AND " + ContactsContract.Data.MIMETYPE + "=?"+ " AND " + ContactsContract.CommonDataKinds.Organization.TYPE + "=?", new String[]{id, ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE, String.valueOf(ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE)});
                builder.withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, value);
                ops.add(builder.build());
                break;
            }

            case "n":
            {
                // Name
                builder = ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI);
                builder.withSelection(ContactsContract.Data.CONTACT_ID + "=?" + " AND " + ContactsContract.Data.MIMETYPE + "=?", new String[]{id, ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE});
                builder.withValue(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, value);
                ops.add(builder.build());
                break;

            }

            case "email":
            {
                // Name
                builder = ContentProviderOperation.newUpdate(ContactsContract.Data.CONTENT_URI);
                builder.withSelection(ContactsContract.Data.CONTACT_ID + "=?" + " AND " + ContactsContract.Data.MIMETYPE + "=?", new String[]{id, ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE});
                builder.withValue(ContactsContract.CommonDataKinds.Email.DATA, value);
                ops.add(builder.build());
                break;

            }

            case "fav":
            {

                System.out.println("UPDATING CONTACT FAV " + field + " " + value);
                // Name
                builder = ContentProviderOperation.newUpdate(ContactsContract.Contacts.CONTENT_URI);
                builder.withSelection(ContactsContract.Contacts._ID + "=?", new String[]{id});
                builder.withValue(ContactsContract.Contacts.STARRED, value);
                ops.add(builder.build());
                break;

            }



            default: return;

        }

        // Update
        try
        {
            cr.applyBatch(ContactsContract.AUTHORITY, ops);
        }
        catch (Exception e)
        {
            e.printStackTrace();
        }
    }

    public static void shareContact(Context c, String id)
    {
        String lookupKey = id;
        System.out.println("SHARING COINTACT WITH ID "+id);
        final Uri shareUri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_VCARD_URI, lookupKey);
        final Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType(ContactsContract.Contacts.CONTENT_VCARD_TYPE);
        intent.putExtra(Intent.EXTRA_STREAM, shareUri);


        c.startActivity(Intent.createChooser(intent, "Share contact"));



    }

    public static String getAccounts(Context c)
    {
        Account[] accountList = AccountManager.get(c).getAccounts();

        String accountSelection = "<root>";

        for (int i = 0; i < accountList.length; i++)
        {
            String accountName = accountList[i].name;
            String accountType = accountList[i].type;

            accountSelection += "<account><name>" + accountName + "</name><type>" + accountType + "</type></account>";

        }

        accountSelection += "</root>";
        return accountSelection;
    }

    public static List<HashMap<String, String>> callLogs(Context c)
    {

        System.out.println("GETTING CALL LOGS");
        List<HashMap<String,String>> res =  new ArrayList<HashMap<String, String>>();
        String[] projection = new String[] {
                CallLog.Calls.CACHED_NAME,
                CallLog.Calls.NUMBER,
                CallLog.Calls.TYPE,
                CallLog.Calls.DATE,
                CallLog.Calls.DURATION,
                CallLog.Calls._ID,

        };
        // String sortOrder = ContactsContract.Contacts.DISPLAY_NAME + " COLLATE LOCALIZED ASC";

        Cursor cursor =  c.getContentResolver().query(CallLog.Calls.CONTENT_URI, projection, null, null, null);
        while (cursor.moveToNext())
        {
            String name = cursor.getString(cursor.getColumnIndex(CallLog.Calls.CACHED_NAME));
            String tel = cursor.getString(cursor.getColumnIndex(CallLog.Calls.NUMBER));
            String type = cursor.getString(cursor.getColumnIndex(CallLog.Calls.TYPE)); // https://developer.android.com/reference/android/provider/CallLog.Calls.html#TYPE
            long seconds = cursor.getLong(cursor.getColumnIndex(CallLog.Calls.DATE)); // epoch time - https://developer.android.com/reference/java/text/DateFormat.html#parse(java.lang.String
            String duration = cursor.getString(cursor.getColumnIndex(CallLog.Calls.DURATION));
            String id = cursor.getString(cursor.getColumnIndex(CallLog.Calls._ID));
            String dir = null;
            switch (Integer.parseInt(type))
            {
                case CallLog.Calls.OUTGOING_TYPE:
                    dir = "OUTGOING";
                    break;

                case CallLog.Calls.INCOMING_TYPE:
                    dir = "INCOMING";
                    break;

                case CallLog.Calls.MISSED_TYPE:
                    dir = "MISSED";
                    break;
            }


            SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy HH:mm");
            String time = formatter.format(new Date(seconds));

            HashMap map = new HashMap<String, String>();
            map.put("n", name == null ? (tel == null ? "" : tel): name);
            map.put("tel", tel == null ? "" : tel);
            map.put("type", dir == null ? "" : dir);
            map.put("duration", duration == null ? "" : duration);
            map.put("id", id == null ? "" : id);
            map.put("date", time == null ? "" : time);
            res.add(map);
        }
        cursor.close();

        return res;
    }

}
