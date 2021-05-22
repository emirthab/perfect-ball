using Godot;
using System;

public class player_movement : RigidBody
{
    private Vector2 firstPos = new Vector2(0,0);
    private Vector2 currentPos;

    [Export]
    private float speedRatio;

    [Export]
    private float maxVelocity;

    //pivot' s lookAt vector so this is targetLook node' s position.
    private Vector3 lookVector(){
        Position3D targetLook = GetNode<Position3D>("../../targetLook");
        Vector3 targetOrgin = targetLook.Transform.origin;
        return targetOrgin;
    }
    public override void _Ready()
    {
        GetNode<Area>("../../finish").Connect("body_entered",this,"finishEntered");   
    }

    public override void _PhysicsProcess(float delta)
    {

        //The result is calculated by subtracting the first vector from the current vector.

        float posX = (currentPos.x - firstPos.x) * speedRatio;
        float posY = (currentPos.y - firstPos.y) * speedRatio;

        float pivotRotationY = GetNode<Spatial>("../pivot").Rotation.y;
        Vector3 movement = new Vector3(posX,0,posY);

        //rotate swipe touch vector from pivot
        //The player is moved taking into account the direction the pivot is facing.
        movement = movement.Rotated(new Vector3(0,1,0).Normalized(),pivotRotationY);
        movement.Normalized();
        if (firstPos != new Vector2(0,0))
        {
            ApplyImpulse(new Vector3(0,0,0),movement);
        }

        //I can't use Clamp method so I do this.
        //max linear velocity
        if (LinearVelocity.x > maxVelocity)
        {
            LinearVelocity = new Vector3(maxVelocity,0,LinearVelocity.z);
        }
        if (LinearVelocity.z > maxVelocity)
        {
            LinearVelocity = new Vector3(LinearVelocity.x,0,maxVelocity);
        }

        //min linear velocity
        if (LinearVelocity.x < -maxVelocity)
        {
            LinearVelocity = new Vector3(-maxVelocity,0,LinearVelocity.z);
        }
        if (LinearVelocity.z < -maxVelocity)
        {
            LinearVelocity = new Vector3(LinearVelocity.x,0,-maxVelocity);
        }

    }

    public override void _Input(InputEvent inputEvent){
        
        //I used a mouse to debug. will be added as touch.
        //The first clicked (touched) position is assigned to the variable "firstPos".
        //If there is movement, the current mouse position is assigned to the "currentPos" variable.
    
        if (inputEvent is InputEventMouseButton mouseEvent)
        {
        
        if ((mouseEvent.ButtonIndex == 1) && (mouseEvent.IsPressed()))
            {
                firstPos = mouseEvent.Position;

            }
            
        if ((mouseEvent.ButtonIndex == 1) && (!mouseEvent.IsPressed()))
            {
                firstPos = new Vector2(0,0);
            }
        }
        if (inputEvent is InputEventMouseMotion mouseEvent2)
        
        {
            currentPos = mouseEvent2.Position;

        }
    
    }

    public override void _Process(float delta)
    {
        //pivot is looking at targetLook position' s 
        GetNode<Spatial>("../pivot").LookAt(lookVector(),Vector3.Up);

    }
    public void finishEntered(RigidBody body)
    {
        GD.Print("denemee");
    }

}
