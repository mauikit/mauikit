package com.kde.maui.tools;

import android.util.Log;
import android.content.Context;
import android.Manifest;
import android.os.Environment;
import android.app.Activity;
import android.content.Context;
import android.os.StatFs;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FileNotFoundException;
import java.lang.String;
import java.io.IOException;


public class SDCard {
    public static int getNumberOfStorages(final Activity act) {
        Context c = act.getApplicationContext().getApplicationContext();
        File[] file_array = c.getExternalFilesDirs(null);
        return file_array.length;
    }

    public static void getStorageNames(final Activity act) {
        Context c = act.getApplicationContext().getApplicationContext();

        int num =  getNumberOfStorages(act);
        File[] f = c.getExternalFilesDirs(null);

        for(int i = 0; i <num; i++)
        {
            System.out.println(f[i].getAbsolutePath());

            }

        if(isExternalStorageReadable())
        {
            System.out.println("THE DRIVE IS READBLE");

            }else
        {
            System.out.println("THE DRIVE IS NTO READVLE");

            }

        if(isExternalStorageWritable())
        {
            File mediaStorageDir =  new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),"MyDir");
            mediaStorageDir.mkdirs();
            }else

        {
            System.out.println("THE DRIVE IS NTO WRITABLE");
            }

    }

    public static long getStorageTotalSize(String str) {
        StatFs fs = new StatFs(str);
        return fs.getTotalBytes();
    }

    public static long getStorageAvailableSize(String str) {
        StatFs fs = new StatFs(str);
        return fs.getAvailableBytes();
    }

// Java
public static void writeToSDCard(final Activity act) {
    Context c = act.getApplicationContext().getApplicationContext();
    File[] f = c.getExternalFilesDirs(null);
}

public static boolean isExternalStorageWritable() {
    String state = Environment.getExternalStorageState();
    if (Environment.MEDIA_MOUNTED.equals(state)) {
        return true;
    }
    return false;
}

/* Checks if external storage is available to at least read */
public static boolean isExternalStorageReadable() {
    String state = Environment.getExternalStorageState();
    if (Environment.MEDIA_MOUNTED.equals(state) ||
        Environment.MEDIA_MOUNTED_READ_ONLY.equals(state)) {
        return true;
    }
    return false;
}

}
//@Override
//public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults)
//{
//    super.onRequestPermissionsResult(requestCode, permissions, grantResults);

//    if(requestCode == REQUEST_CODE_WRITE_EXTERNAL_STORAGE_PERMISSION)
//    {
//        int grantResultsLength = grantResults.length;
//        if(grantResultsLength > 0 && grantResults[0]==PackageManager.PERMISSION_GRANTED)
//        {
//            Toast.makeText(getApplicationContext(), "You grant write external storage permission. Please click original button again to continue.", Toast.LENGTH_LONG).show();
//        }else
//        {
//            Toast.makeText(getApplicationContext(), "You denied write external storage permission.", Toast.LENGTH_LONG).show();
//        }
//    }

//}
