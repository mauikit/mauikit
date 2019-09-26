/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */
 
package com.kde.maui.tools;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.Manifest;
import android.net.Uri;
import java.io.File;
import android.provider.ContactsContract;
import android.database.Cursor;
import android.telephony.gsm.SmsManager;

public class SendIntent
{
    private static final int READ_REQUEST_CODE = 42;
	private static final int CONTACT_PICKER_RESULT = 1001;

    public static void sendText(Activity context, String text)
    {
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, text);
        sendIntent.setType("text/plain");
        context.startActivity(Intent.createChooser(sendIntent, text));
    }
    
    public static void sendSMS(Activity context, String tel, String subject, String message)
    {
        SmsManager smsManager = SmsManager.getDefault();
                smsManager.sendTextMessage(tel, null, message, null, null);
	}


    public static void sendUrl(Activity context, String text)
    {
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_TEXT, text);
        sendIntent.setType("text/plain");
        context.startActivity(Intent.createChooser(sendIntent, text));
    }

public static void requestPermission(Activity context)
{
    System.out.println("REQUETSIN FUCKIGN PERMSISSION");
            context.requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE,
                        Manifest.permission.READ_EXTERNAL_STORAGE}, 1);

        }

    public static void share(Activity context, String url, String mime)
    {
        File file = new File(url);
        System.out.println(file.exists());
        Uri uri = Uri.fromFile(file);
        Intent sendIntent = new Intent();
        sendIntent.setAction(Intent.ACTION_SEND);
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri);
        System.out.println(mime);
        sendIntent.setType(mime);
//        sendIntent.setDataAndType(uri, mime);

        context.startActivity(Intent.createChooser(sendIntent, "Share"));
    }

    public static void openFile(Activity context, String url)
    {
        File file = new File(url);
        Uri uri = Uri.fromFile(file);
        String mime = context.getContentResolver().getType(uri);


        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_GET_CONTENT);

        intent.setDataAndType(uri, mime);
        context.startActivity(Intent.createChooser(intent, "Open folder"));

    }

     public static void fileChooser(Activity context)
     {
             Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
             intent.addCategory(Intent.CATEGORY_OPENABLE);
             intent.setType("audio/*");
             context.startActivityForResult(intent, READ_REQUEST_CODE);
      }

  public static void call(Activity context, String tel)
  {
      Intent callIntent = new Intent(Intent.ACTION_CALL);
//        callIntent.setPackage("com.android.phone");          // force native dialer  (Android < 5)
      callIntent.setPackage("com.android.server.telecom"); // force native dialer  (Android >= 5)
      callIntent.setData(Uri.parse("tel:" + tel));
      callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      context.startActivity(callIntent);
  }
}
