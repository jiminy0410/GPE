using System.Collections;
using UnityEngine;

public class meshGoBrr : MonoBehaviour
{
    Mesh mesh;
    [SerializeField] int gridSizeX = 10;
    [SerializeField] int gridSizeZ = 10;

    [SerializeField] float waveFrequency = 2f;
    [SerializeField] float waveAmplitude = 0.5f;

    [SerializeField] bool wave;

    void Start()
    {
        mesh = new Mesh();

        // Calculate total number of vertices
        int numVertices = gridSizeX * gridSizeZ;

        // Initialize arrays to hold vertices and triangles
        Vector3[] vertices = new Vector3[numVertices];
        int[] triangles = new int[(gridSizeX - 1) * (gridSizeZ - 1) * 6];

        // Generate grid of vertices
        for (int z = 0, i = 0; z < gridSizeZ; z++)
        {
            for (int x = 0; x < gridSizeX; x++)
            {
                // Calculate vertex positions
                float xPos = x;
                float zPos = z;

                // Set vertex position in array
                vertices[i] = new Vector3(xPos, 0, zPos);
                i++;
            }
        }

        // Assign vertices to mesh
        mesh.vertices = vertices;

        // Generate triangles
        for (int ti = 0, vi = 0, y = 0; y < gridSizeZ - 1; y++, vi++)
        {
            for (int x = 0; x < gridSizeX - 1; x++, ti += 6, vi++)
            {
                // Assign vertex indices to form triangles
                triangles[ti] = vi;
                triangles[ti + 3] = triangles[ti + 2] = vi + 1;
                triangles[ti + 4] = triangles[ti + 1] = vi + gridSizeX;
                triangles[ti + 5] = vi + gridSizeX + 1;
            }
        }

        // Assign triangles to mesh
        mesh.triangles = triangles;

        // Recalculate normals for smooth shading
        mesh.RecalculateNormals();

        // Assign the mesh to the MeshFilter component
        GetComponent<MeshFilter>().mesh = mesh;
    }
     
    private void Update()
    {
        if (wave)
        {
            // Get the current vertices of the mesh
            Vector3[] vertices = mesh.vertices;

            // Loop through all vertices and modify their y-coordinates
            for (int i = 0; i < vertices.Length; i++)
            {
                // Calculate the displacement using a sine wave function
                float displacement = Mathf.Sin(Time.time * waveFrequency + vertices[i].x) * waveAmplitude;

                // Update the y-coordinate of the vertex with the displacement
                vertices[i] = new Vector3(vertices[i].x, displacement, vertices[i].z);
            }

            // Assign the modified vertices back to the mesh
            mesh.vertices = vertices;

            // Recalculate normals to ensure lighting is updated correctly
            mesh.RecalculateNormals();
        }
    }
}
