using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    public float daySpeed = 10f; // Rotation speed during the day
    public float nightSpeed = 5f; // Rotation speed during the night
    public float transitionPoint = 90f; // Angle at which transition occurs (in degrees)
    public bool isDaytime = true; // Flag to indicate if it's daytime or nighttime

    private float rotationSpeed; // Current rotation speed

    void FixedUpdate()
    {
        // Check the current angle of rotation around the y-axis
        float angle = transform.rotation.eulerAngles.y;

        // Check if the angle has passed the transition point
        if (angle >= transitionPoint && isDaytime)
        {
            // Transition from day to night
            isDaytime = false;
        }
        else if (angle <= transitionPoint && !isDaytime)
        {
            // Transition from night to day
            isDaytime = true;
        }

        // Set rotation speed based on whether it's daytime or nighttime
        rotationSpeed = isDaytime ? daySpeed : nightSpeed;

        // Rotate the object around the y-axis
        transform.Rotate(Vector3.up * rotationSpeed * Time.deltaTime);
    }
}
