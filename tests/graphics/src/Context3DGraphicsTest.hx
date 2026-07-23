package;

import openfl.display.Shape;
import openfl.display._internal.Context3DGraphics;
import utest.Assert;
import utest.Test;

@:access(openfl.display._internal.Context3DGraphics)
@:access(openfl.display.Graphics)
class Context3DGraphicsTest extends Test
{
	public function testOrdinaryHardwareGraphicsDoNotRequireRectangleBatchPreparation():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawCircle(0, 0, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isFalse(shape.graphics.__rectangleBatchesRequired);
	}

	public function testSingleDrawRectDoesNotRequireRectangleBatchPreparation():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isFalse(shape.graphics.__rectangleBatchesRequired);
	}

	public function testDisjointDrawRectsAreCompatible():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(20, 0, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isTrue(shape.graphics.__rectangleBatchesRequired);
	}

	public function testTouchingDrawRectsAreCompatible():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(10, 0, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
	}

	public function testRectangleBatchRequirementIsClearedWhenCommandsChange():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(20, 0, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isTrue(shape.graphics.__rectangleBatchesRequired);

		shape.graphics.clear();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawCircle(0, 0, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isFalse(shape.graphics.__rectangleBatchesRequired);
	}

	public function testOverlappingDrawRectsAreCompatible():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(5, 5, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
	}

	public function testNestedDrawRectsAreCompatible():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 20, 20);
		shape.graphics.drawRect(5, 5, 5, 5);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
	}

	public function testNegativeSizeDrawRectsUseNormalizedBounds():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(10, 10, -10, -10);
		shape.graphics.drawRect(20, 0, -5, 5);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
	}
}
