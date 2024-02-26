using UnityEngine;

public class meshGoBrr2 : MonoBehaviour
{
    Mesh mesh;
    // Number of vertices along the circumference of the circle
    public int numVertices;
    public int rings;
    // Radius of the circle
    public float radius;

    public float hight;

    public Material materialToUse;

    void Start()
    {
        mesh = new Mesh();
        numVertices++;

        // Initialize arrays to hold vertices and triangles
        Vector3[] vertices = new Vector3[numVertices * rings];
        Vector2[] uvs = new Vector2[numVertices * rings];
        int[] triangles = new int[(numVertices * rings + 1) * 3];

        // Generate vertices in a circular pattern
        for (int i = 0; i < rings; i++)
        {
            float rotationY = Random.Range(0f, 360f); // Random rotation for each ring

            for (int j = 0; j < numVertices; j++)
            {
                // Calculate the angle for each vertex
                float angle = Mathf.PI * 2 * j / (numVertices - 2);

                // Calculate the position of the vertex using trigonometry
                float x = Mathf.Cos(angle) * ((i - rings - 1) / radius);
                float z = Mathf.Sin(angle) * ((i - rings - 1) / radius);

                // Apply random rotation around the y-axis
                Vector3 vertexPosition = new Vector3(x, i * hight, z);
                vertexPosition = Quaternion.Euler(0f, rotationY, 0f) * vertexPosition;

                if (j == 0)
                {
                    // Set the middel vertex position
                    vertices[j + i * numVertices] = new Vector3(0, rings * hight, 0);
                    // Calculate middle UV coordinates based on vertex position
                    uvs[j + i * numVertices] = new Vector2(0.5f, 0.5f);
                }
                else
                {
                    // Set the vertex position
                    vertices[j + i * numVertices] = vertexPosition;
                    // Calculate UV coordinates based on vertex position
                    uvs[j + i * numVertices] = new Vector2((x + ((i - rings - 1) / radius)) / (((i - rings - 1) / radius) * 2), (z + ((i - rings - 1) / radius)) / (((i - rings - 1) / radius) * 2));
                }
            }
            //Debug.Log(vertices[i]);
            // Generate triangles to form the circle
            for (int j = 0; j < numVertices - 1; j++)
            {
                int baseIndex = (j + i * numVertices) * 3; // Base index for the current triangle

                triangles[baseIndex] = 0;  // Central vertex
                triangles[baseIndex + 1] = j + 1 + i * numVertices; // Vertex after the current one
                triangles[baseIndex + 2] = j + i * numVertices; // Current vertex
            }
        }

        // Assign vertices to mesh
        mesh.vertices = vertices;
        mesh.uv = uvs;
        // Assign triangles to mesh
        mesh.triangles = triangles;

        // Recalculate normals for correct shading
        mesh.RecalculateNormals();

        // Assign the mesh to the MeshFilter component
        GetComponent<MeshFilter>().mesh = mesh;

        GetComponent<MeshRenderer>().material = materialToUse;
    }
}
