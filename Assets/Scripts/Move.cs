using UnityEngine;
using UnityEngine.UI;

public class Move : MonoBehaviour
{
    public Rigidbody playerRb;
    public float moveSpeed;
    private Vector2 movementInput;
    public bool jump;
    public float jumpForce;

    void Start()
    {
        playerRb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        movementInput = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));

        // Check if the spacebar is pressed
        if (Input.GetKeyDown(KeyCode.Space))
        {
            // Set jump to true
            jump = true;
        }
    }

    private void FixedUpdate()
    {
        if (movementInput != Vector2.zero)
        {
            Go(movementInput);
        }

        // Check if jump is true
        if (jump)
        {
            // Apply vertical force to simulate jump
            playerRb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);

            // Reset jump to false to prevent continuous jumping
            jump = false;
        }
    }

    void Go(Vector2 input)
    {
        playerRb.AddForce(new Vector3(input.x, 0.1f, input.y).normalized * moveSpeed, ForceMode.Acceleration);
        transform.position = new Vector3(transform.position.x + input.x * (moveSpeed) * 0.01f, transform.position.y, transform.position.z + input.y * (moveSpeed)*0.05f);
    }

    private void OnTriggerEnter(Collider other)
    {
    }
}
