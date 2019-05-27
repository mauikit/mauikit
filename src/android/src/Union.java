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

        String tel = "", email = "", org = "", title = "";

        ContentResolver cr = c.getContentResolver();

        //ADD PHONE DATA...
        Cursor phoneCursor = cr.query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                null,
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                new String[]{id},
                null);

        if (phoneCursor != null)
            if (phoneCursor.moveToFirst())
                tel = phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));


        if (phoneCursor != null)
            phoneCursor.close();


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


        res.put("tel", tel == null ? "" : tel);
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

    public static List<HashMap<String, String>> fetchContacts(Context c)
    {
        System.out.println("FETCHING CONTACTS");
        List<HashMap<String,String>> res =  new ArrayList<HashMap<String, String>>();

        String[] projection = new String[] {
               ContactsContract.Contacts._ID,
               ContactsContract.Contacts.DISPLAY_NAME,
                ContactsContract.Contacts.STARRED,
               ContactsContract.Contacts.PHOTO_URI
        };

        ContentResolver cr = c.getContentResolver();
        Cursor mainCursor = cr.query(ContactsContract.Contacts.CONTENT_URI, projection, null, null, null);

        if (mainCursor != null)
        {
            while (mainCursor.moveToNext())
            {
                String id = "", name  = "", fav = "", accountType= "", accountName = "", photo = "";
//ByteArrayInputStream photo = null;
                id = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts._ID));
                name = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME));
                fav = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.STARRED));
                photo = mainCursor.getString(mainCursor.getColumnIndex(ContactsContract.Contacts.PHOTO_URI));

                //ADD ACCOUNT DATA...

                String[] accountProjection = new String[] {
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


                HashMap<String, String> contact = new HashMap<String, String>();
                contact.put("n", name == null ? "" : name);
                contact.put("id", id == null ? "" : id);
                contact.put("fav", fav == null ? "" : fav);
                contact.put("photo", photo == null ? "" : photo);
                contact.put("account", accountName == null ? "" : accountName);
                contact.put("type", accountType == null ? "" : accountType);
                res.add(contact);
            }
        }

        if (mainCursor != null)
            mainCursor.close();

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
