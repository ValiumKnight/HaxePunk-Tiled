package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import flash.display.BitmapData;

typedef TileFunction = Int -> Int -> Int -> Bool;

class TmxEntity extends Entity
{
	
	public var tilemaps:Array<Graphic>;
	public var map:TmxMap;

	public function new(mapData:Dynamic, bitmapData:BitmapData, displayFunc:TileFunction) 
	{
		super();
		var tilemap:Tilemap;
		
		tilemaps = new Array<Graphic>();
		if (Std.is(mapData, TmxMap)) {
			map = mapData;
		} else {
			map = new TmxMap(mapData);
		}
		
		for (layer in map.layers)
		{
			tilemap = new Tilemap(bitmapData, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
			// Loop through tile layer ids
			for (row in 0...layer.tileGIDs.length)
			{
				for (col in 0...layer.tileGIDs[row].length)
				{
					// if the tile is not null, set it
					if (displayFunc(layer.tileGIDs[row][col], row, col))
					{
						tilemap.setTile(col, row, layer.tileGIDs[row][col] - 1);
					}
				}
			}
			tilemaps.push(tilemap);
		}
		
		graphic = new Graphiclist(tilemaps);
	}
	
	public function setCollidable(collideFunc:TileFunction, collideLayer:String = "collide")
	{
		var collide:TmxLayer = null;
		_grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
		
		for (layer in map.layers)
		{
			collide = layer;
			if (layer.name == collideLayer)
			{
				break;
			}
		}
		
		if (collide == null) return;
		
		// Loop through tile layer ids
		for (row in 0...collide.tileGIDs.length)
		{
			for (col in 0...collide.tileGIDs[row].length)
			{
				if (collideFunc(collide.tileGIDs[row][col], row, col))
				{
					_grid.setTile(col, row, true);
				}
			}
		}
		
		mask = _grid;
		type = "solid";
		setHitbox(_grid.width, _grid.height);
	}
	
	private var _grid:Grid;
	
}