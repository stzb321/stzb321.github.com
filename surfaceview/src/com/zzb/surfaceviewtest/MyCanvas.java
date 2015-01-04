package com.zzb.surfaceviewtest;

import java.util.Timer;
import java.util.TimerTask;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class MyCanvas extends SurfaceView implements SurfaceHolder.Callback{
	
	private Timer timer;
	private TimerTask task;
	private float x = 0;
	private float y = 0;
	private float width = 40;
	private float height = 40;
	private float speedX = 2;
	private float speedY = 3;
	private Paint paint = new Paint();
	
	public MyCanvas(Context context) {
		super(context);
		paint.setColor(Color.BLUE);
		getHolder().addCallback(this);
	}

	public MyCanvas(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
		paint.setColor(Color.BLUE);
		getHolder().addCallback(this);
	}

	public MyCanvas(Context context, AttributeSet attrs) {
		super(context, attrs);
		paint.setColor(Color.BLUE);
		getHolder().addCallback(this);
	}


	public void draw() {
		//锁定画布
		Canvas canvas = getHolder().lockCanvas();
		canvas.drawColor(Color.WHITE);
		canvas.drawRect(x, y, x+width, y+height, paint);
		if(x < 0 || x > canvas.getWidth()){
			speedX = -speedX;
		}
		if(y < 0 || y > canvas.getHeight()){
			speedY = -speedY;
		}
		x = x+speedX;
		y = y+speedY;
		//解锁画布
		getHolder().unlockCanvasAndPost(canvas);
	}
	
	public void startTimer(){
		timer = new Timer();
		task = new TimerTask() {
			
			@Override
			public void run() {
				draw();
			}
		};
		timer.schedule(task, 40 , 100);
	}
	
	public void stopTimer(){
		timer.cancel();
	}

	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		startTimer();
		
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		
		
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		stopTimer();
		
	}

}
