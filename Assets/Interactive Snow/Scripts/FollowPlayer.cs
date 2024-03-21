using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowPlayer : MonoBehaviour
{
    [SerializeField]
    Transform target;
    private Vector3 offset;
    [SerializeField]
    float offsetx;
    [SerializeField]
    float offsetz;
    [SerializeField]
    float offsety;
    // Start is called before the first frame update
    void Start()
    {
        offset = transform.position - target.position;
        offsetx = offset.x;
        offsety = offset.y;
        offsetz = offset.z;
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = new Vector3(target.position.x + offset.x, target.position.y + offset.y, target.position.z + offset.z);
        //transform.position = new Vector3(target.position.x, target.position.y, target.position.z);
    }
}
