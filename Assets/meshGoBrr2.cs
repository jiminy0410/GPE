using UnityEngine;

public class meshGoBrr2 : MonoBehaviour
{
    Mesh mesh;
    // Number of vertices along the circumference of the circle
    public int numVertices;
    // Radius of the circle
    public float radius;

    public Material materialToUse;

    void Start()
    {
        mesh = new Mesh();
        numVertices++;

        // Initialize arrays to hold vertices and triangles
        Vector3[] vertices = new Vector3[numVertices];
        Vector2[] uvs = new Vector2[numVertices];
        int[] triangles = new int[(numVertices + 1) * 3];

        // Generate vertices in a circular pattern
        for (int i = 0; i < numVertices; i++)
        {
            // Calculate the angle for each vertex
            float angle = Mathf.PI * 2 * i / (numVertices - 1);

            // Calculate the position of the vertex using trigonometry
            float x = Mathf.Cos(angle) * radius;
            float z = Mathf.Sin(angle) * radius;
            if (i == 0)
            {
                // Set the middel vertex position
                vertices[i] = new Vector3(0, 1, 0);
                // Calculate middel UV coordinates based on vertex position
                uvs[i] = new Vector2(0.5f, 0.5f);
            }
            else
            {
                // Set the vertex position
                vertices[i] = new Vector3(x, 0, z);
                // Calculate UV coordinates based on vertex position
                uvs[i] = new Vector2((x + radius) / (radius * 2), (z + radius) / (radius * 2));
            }
            //Debug.Log(vertices[i]);
        }

        // Assign vertices to mesh
        mesh.vertices = vertices;
        mesh.uv = uvs;

        // Generate triangles to form the circle
        for (int i = 0; i < numVertices - 2; i++)
        {
            triangles[i * 3] = 0;          // The first vertex (center of the circle)
            triangles[i * 3 + 1] = i + 2;  // The vertex after that
            triangles[i * 3 + 2] = i + 1;  // The next vertex
            if (i == numVertices - 3)
            {
                triangles[(i + 1) * 3] = 0;
                triangles[(i + 1) * 3 + 1] = 1;
                triangles[(i + 1) * 3 + 2] = i + 2;
            }
        }

        // Assign triangles to mesh
        mesh.triangles = triangles;

        // Recalculate normals for correct shading
        mesh.RecalculateNormals();

        // Assign the mesh to the MeshFilter component
        GetComponent<MeshFilter>().mesh = mesh;

        GetComponent<MeshRenderer>().material = materialToUse;
    }

}
