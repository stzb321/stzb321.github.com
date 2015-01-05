package com.zzb.popstar;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;

public class GameView extends SurfaceView implements SurfaceHolder.Callback {
	
	private Thread drawThread;
	private volatile boolean drawFlag = false;
	
	public GameView(Context context) {
		super(context);
		initView();
	}

	public GameView(Context context, AttributeSet attrs, int defStyleAttr) {
		super(context, attrs, defStyleAttr);
		initView();
	}

	public GameView(Context context, AttributeSet attrs) {
		super(context, attrs);
		initView();
	}

	private static int starW = 64 , starH = 64;
	private int height = 0;
	private int row = 10 , col = 10;
	private int space = 8;
	private List<Star> selectStars = new ArrayList<Star>();
	private List<ArrayList<Star>> starArr = new ArrayList<ArrayList<Star>>();
	private static String[] colorArr = {"blue","green","purple","red","yellow"};
	
	public void initView(){
		setFocusable(true);
		initStarArr();
		getHolder().addCallback(this); //这句执行完了之后,马上就会回调 surfaceCreated方法了 然后开启thread
	}
	
	protected void draw() {
		Canvas canvas = getHolder().lockCanvas();
		canvas.drawColor(Color.BLACK);
		for(int i=0 ; i < starArr.size() ; i ++){
			for(int j=0 ; j < starArr.get(i).size() ; j ++){
				Star star = starArr.get(i).get(j);
				int row = star.getRow();
				int col = star.getCol();
				canvas.drawBitmap(star.getBmp(), col*(starW+space), height - (row+1)*(starW+space), new Paint());
			}
		}
		getHolder().unlockCanvasAndPost(canvas);
	}
	
	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh) {
		height = h;
		super.onSizeChanged(w, h, oldw, oldh);
	}

	public void initStarArr(){
		for(int i=0 ; i < col ; i ++){
			ArrayList<Star> oneCol = new ArrayList<Star>();
			for(int j=0 ; j < row ; j ++){
				Random r = new Random();
				String color = colorArr[r.nextInt(5)];
				Star star = new Star(color,j,i,getResources());
				oneCol.add(star);
			}
			starArr.add(oneCol);
		}
	}
	
	@SuppressLint("ClickableViewAccessibility")
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		Star star = getTouchStar(event.getX(), event.getY());
		if(star == null){
			return super.onTouchEvent(event);
		}
		if(selectStars.size() != 0){
			if(!isContain(star)){
				for(Star s : selectStars){
					s.toggleScale();
				}
				selectStars = new ArrayList<Star>();
			}else{
				destoryStar();
			}
		}else{
			seekStar(star);
			if(selectStars.size() > 1){
				for(Star s : selectStars){
					s.toggleScale();
				}
			}else{
				selectStars = new ArrayList<Star>();
			}
		}
		return super.onTouchEvent(event);
	}
	
	private Star getTouchStar(float x, float y){
		try{
			int col = (int) Math.floor(x/(starW+space));
			int row = (int) Math.floor((this.height-y)/(starH+space));
			return starArr.get(col).get(row);
		}catch(Exception e){
			return null;
		}
	}
	
	/**
	 * 寻找相同的星星
	 * @param star
	 */
	private void seekStar(Star star){
		try{
			int starRow = star.getRow();
			int starCol = star.getCol();
			if(isContain(star)){
				return;
			}
			if( selectStars.size() == 0 || !isContain(star)){
				selectStars.add(star);
			}
			
			//向上寻找
			int topLength = starArr.get(starCol).size();
			if(starRow+1 >= topLength){
				return;
			}else if(starArr.get(starCol).get(starRow+1).getColor().equals(star.getColor())){
				seekStar(starArr.get(starCol).get(starRow+1));
			}
			
			//向右寻找
			int rightLength = starArr.size();
			if(starCol+1 >= rightLength){
				return;
			}else if(starArr.get(starCol+1).get(starRow).getColor().equals(star.getColor())){
				seekStar(starArr.get(starCol+1).get(starRow));
			}
			
			//向下寻找
			if(starRow-1 < 0){
				return;
			}else if(starArr.get(starCol).get(starRow-1).getColor().equals(star.getColor())){
				seekStar(starArr.get(starCol).get(starRow-1));
			}
			
			//向左寻找
			if(starCol-1 < 0){
				return;
			}else if(starArr.get(starCol-1).get(starRow).getColor().equals(star.getColor())){
				seekStar(starArr.get(starCol-1).get(starRow));
			}
		}catch(Exception e){
			return;
		}
	}
	
	private void destoryStar(){
		for(Star s : selectStars){
			int starCol = s.getCol();
			int starRow = s.getRow();
			if(starArr.get(starCol).size() == 0){
				starArr.remove(starCol);
				updateCol(starCol);
			}else{
				starArr.get(starCol).remove(starRow);
				updateRow(starCol,starRow);
			}
		}
		selectStars = new ArrayList<Star>();
	}
	
	private boolean isContain(Star star){
		boolean flag = false;
		for(Star s : selectStars){
			if(s.equals(star)){
				flag = true;
			}
		}
		return flag;
	}
	
	private void updateRow(int starCol, int starRow){
		if(starCol >= starArr.size() || starRow >= starArr.get(starCol).size()){
			return;
		}
		for(int i=starRow; i<starArr.get(starCol).size(); i++){
			Star s = starArr.get(starCol).get(i);
			s.setRow(s.getRow()-1);
		}
	}
	
	private void updateCol(int starCol){
		if(starCol >= starArr.size()){
			return;
		}
		for(int i=starCol; i < starArr.size() ; i++){
			for(int j=0; j<starArr.get(i).size() ; j++){
				Star s = starArr.get(i).get(j);
				s.setCol(i);
			}
		}
	}

	/****************************************************************************/
	
	public void startDraw(){
		drawFlag = true;
		drawThread = new Thread(new Runnable() {
			
			@SuppressWarnings("static-access")
			@Override
			public void run() {
				while(drawFlag){
					draw();
					try {
						drawThread.sleep(40);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
		});
		drawThread.start();
	}
	
	public void stopDraw(){
		drawFlag = false;
		drawThread.interrupt();
	}
	
	@Override
	public void surfaceCreated(SurfaceHolder holder) {
		startDraw();
	}

	@Override
	public void surfaceChanged(SurfaceHolder holder, int format, int width,
			int height) {
		
	}

	@Override
	public void surfaceDestroyed(SurfaceHolder holder) {
		stopDraw();
	}

}
