package com.zzb.popstar;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

public class GameView extends View {
	
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
	private int width =0 , height = 0;
	private int row = 10 , col = 10;
	private int space = 8;
	private List<Star> selectStars = new ArrayList<Star>();
	private List<ArrayList<Star>> starArr = new ArrayList<ArrayList<Star>>();
	private static String[] colorArr = {"blue","green","purple","red","yellow"};
	
	public void initView(){
		setFocusable(true);
		initStarArr();
	}
	
	@SuppressLint("DrawAllocation")
	@Override
	protected void onDraw(Canvas canvas) {
		for(int i=0 ; i < starArr.size() ; i ++){
			for(int j=0 ; j < starArr.get(i).size() ; j ++){
				Star star = starArr.get(i).get(j);
				int row = star.getRow();
				int col = star.getCol();
				canvas.drawBitmap(star.getBmp(), col*(starW+space), height - (row+1)*(starW+space), new Paint());
			}
		}
		super.onDraw(canvas);
	}
	
	@Override
	protected void onSizeChanged(int w, int h, int oldw, int oldh) {
		width = w;
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
		invalidate();
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
			int row = star.getRow();
			int col = star.getCol();
			if(isContain(star)){
				return;
			}
			if( selectStars.size() == 0 || !isContain(star)){
				selectStars.add(star);
			}
			
			//向上寻找
			int topLength = starArr.get(col).size();
			if(row+1 >= topLength){
				return;
			}else if(starArr.get(col).get(row+1).getColor().equals(star.getColor())){
				seekStar(starArr.get(col).get(row+1));
			}
			
			//向右寻找
			int rightLength = starArr.size();
			if(col+1 >= rightLength){
				return;
			}else if(starArr.get(col+1).get(row).getColor().equals(star.getColor())){
				seekStar(starArr.get(col+1).get(row));
			}
			
			//向下寻找
			if(row-1 < 0){
				return;
			}else if(starArr.get(col).get(row-1).getColor().equals(star.getColor())){
				seekStar(starArr.get(col).get(row-1));
			}
			
			//向左寻找
			if(col-1 < 0){
				return;
			}else if(starArr.get(col-1).get(row).getColor().equals(star.getColor())){
				seekStar(starArr.get(col-1).get(row));
			}
		}catch(Exception e){
			return;
		}
	}
	
	private void destoryStar(){
		for(Star s : selectStars){
			int col = s.getCol();
			int row = s.getRow();
			starArr.get(col).remove(row);
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

	/*******************************************************************************/
	public class Coordinate{
		public int x;
		public int y;
		public Coordinate(int x , int y){
			this.x = x;
			this.y = y;
		}
		
		public boolean equals(Coordinate o) {
			return this.x == o.x && this.y == o.y;
		}

		@Override
		public String toString() {
			return new StringBuffer().append("x = ").append(x).append(" , y = ").append(y).toString();
		}
	}

}
