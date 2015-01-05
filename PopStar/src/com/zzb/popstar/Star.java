package com.zzb.popstar;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class Star{
	
	public String color;
	public int row;
	public int col;
	public Bitmap bmp;
	public boolean scaleState = false;//true:∑≈¥Û    false:Àı–°
	public static int starW = 64, starH = 64;
	
	public String getColor() {
		return color;
	}

	public void setColor(String color) {
		this.color = color;
	}

	public int getRow() {
		return row;
	}

	public void setRow(int row) {
		this.row = row;
	}

	public int getCol() {
		return col;
	}

	public void setCol(int col) {
		this.col = col;
	}

	public Bitmap getBmp() {
		return bmp;
	}

	public void setBmp(Bitmap bmp) {
		this.bmp = bmp;
	}

	/**
	 * @param color
	 * @param row
	 * @param col
	 * @param res
	 */
	public Star(String color, int row, int col, Resources res) {
		super();
		this.color = color;
		this.row = row;
		this.col = col;
		int id = 0;
		if(color.equals("blue")){
			id = R.drawable.star_blue;
		}else if(color.equals("green")){
			id = R.drawable.star_green;
		}else if(color.equals("red")){
			id = R.drawable.star_red;
		}else if(color.equals("purple")){
			id = R.drawable.star_purple;
		}else if(color.equals("yellow")){
			id = R.drawable.star_yellow;
		}
		this.bmp = BitmapFactory.decodeResource(res, id);
	}
	
	public void toggleScale(){
		if(scaleState){
			zoomOut();
		}else{
			zoomIn();
		}
	}
	
	public void zoomIn(){
		scaleState = true;
		int w = this.bmp.getWidth() , h = this.bmp.getHeight();
		Bitmap bitmap = Bitmap.createScaledBitmap(this.bmp, (int)(w*1.1), (int)(h*1.1), true);
		this.bmp.recycle();
		this.bmp = bitmap;
	}
	
	public void zoomOut(){
		scaleState = false;
		Bitmap bitmap = Bitmap.createScaledBitmap(this.bmp, starW, starH, true);
		this.bmp.recycle();
		this.bmp = bitmap;
	}

	public boolean equals(Star s) {
		return this.col == s.col && this.row == s.row && this.color.equals(s.color);
	}
}
