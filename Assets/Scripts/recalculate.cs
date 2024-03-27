using UnityEngine;

public class Example : MonoBehaviour
{
    Mesh mesh;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().mesh;
    }
    private void Update()
    {
        mesh.RecalculateNormals();
    }
}