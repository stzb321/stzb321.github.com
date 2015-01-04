package com.zzb.popstar;

import com.zzb.popstar.util.SystemUiHider;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

/**
 * An example full-screen activity that shows and hides the system UI (i.e.
 * status bar and navigation/system bar) with user interaction.
 * 
 * @see SystemUiHider
 */
public class StartScene extends Activity {
	
	private Button startBtn;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		setContentView(R.layout.activity_start_scene);
		
		startBtn = (Button)findViewById(R.id.startBtn);
		startBtn.setOnClickListener(startBtnListener);
	}
	
	public OnClickListener startBtnListener = new OnClickListener() {
		@Override
		public void onClick(View v) {
			Intent intent = new Intent();
			intent.setClass(StartScene.this, GameScene.class);
			startActivity(intent);
			StartScene.this.finish();
		}
	};
}
