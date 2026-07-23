package;

import openfl.display.Shape;
import openfl.display._internal.Context3DGraphics;
import openfl.display._internal.DrawCommandType;
import openfl.Vector;
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
		shape.graphics.drawTriangles(Vector.ofArray([0.0, 0.0, 10.0, 0.0, 0.0, 10.0]));
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isFalse(shape.graphics.__rectangleBatchesRequired);
		Assert.isNull(shape.graphics.__hardwareCommands);
	}

	public function testSingleDrawRectDoesNotRequireRectangleBatchPreparation():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.isFalse(shape.graphics.__rectangleBatchesRequired);
		Assert.isNull(shape.graphics.__hardwareCommands);
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
		Assert.notNull(shape.graphics.__hardwareCommands);
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

	public function testPreparedHardwareCommandsPreserveOtherFills():Void
	{
		var shape = new Shape();
		shape.graphics.beginFill(0xFF0000);
		shape.graphics.drawRect(0, 0, 10, 10);
		shape.graphics.drawRect(5, 0, 10, 10);
		shape.graphics.endFill();
		shape.graphics.beginFill(0x00FF00);
		shape.graphics.drawCircle(20, 20, 5);
		shape.graphics.endFill();

		Assert.isTrue(Context3DGraphics.isCompatible(shape.graphics));
		Assert.notNull(shape.graphics.__hardwareCommands);
		Assert.isTrue(shape.graphics.__hardwareCommands.types.indexOf(DrawCommandType.DRAW_QUADS) >= 0);
		Assert.isTrue(shape.graphics.__hardwareCommands.types.indexOf(DrawCommandType.DRAW_CIRCLE) >= 0);
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
		shape.graphics.drawTriangles(Vector.ofArray([0.0, 0.0, 10.0, 0.0, 0.0, 10.0]));
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
