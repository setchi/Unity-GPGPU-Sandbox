using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityGpuSandbox.VertexParticle
{
    public partial class VertexParticle : MonoBehaviour
    {
        [SerializeField]
        Shader kernelShader;
        [SerializeField]
        Shader debugShader;
        [SerializeField]
        Material material;
        [SerializeField]
        bool debug = false;

        RenderTexture positionBuffer1;
        RenderTexture positionBuffer2;
        RenderTexture velocityBuffer1;
        RenderTexture velocityBuffer2;
        Material kernelMaterial;
        Material debugMaterial;
        MaterialPropertyBlock props;
        Mesh mesh;

        bool needsReset = true;

        int width = 1000;
        int height = 1000;

        RenderTexture CreateBuffer()
        {
            var buffer = new RenderTexture(width, height, 0, RenderTextureFormat.ARGBFloat);
            buffer.hideFlags = HideFlags.DontSave;
            buffer.filterMode = FilterMode.Point;
            buffer.wrapMode = TextureWrapMode.Repeat;
            return buffer;
        }

        Material CreateMaterial(Shader shader)
        {
            var material = new Material(shader);
            material.hideFlags = HideFlags.DontSave;
            return material;
        }

        Mesh CreateMesh()
        {
            var numPoints = height * width;

            var points = new Vector3[numPoints];
            var indecies = new int[numPoints];
            var colors = new Color[numPoints];
            var uv = Vector2.zero;

            for (int i = 0; i < numPoints; i++)
            {
                uv.x = i % width;
                uv.y = i / height;
                uv.x /= width;
                uv.y /= height;
                points[i] = new Vector3(uv.x, uv.y, 0);
                indecies[i] = i;
                colors[i] = new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f);
            }

            var mesh = new Mesh();
            mesh.vertices = points;
            mesh.colors = colors;
            mesh.SetIndices(indecies, MeshTopology.Points, 0);
            return mesh;
        }

        void ResetResources()
        {
            mesh = CreateMesh();

            if (positionBuffer1) DestroyImmediate(positionBuffer1);
            if (positionBuffer2) DestroyImmediate(positionBuffer2);
            if (velocityBuffer1) DestroyImmediate(velocityBuffer1);
            if (velocityBuffer2) DestroyImmediate(velocityBuffer2);

            positionBuffer1 = CreateBuffer();
            positionBuffer2 = CreateBuffer();
            velocityBuffer1 = CreateBuffer();
            velocityBuffer2 = CreateBuffer();

            if (!kernelMaterial) kernelMaterial = CreateMaterial(kernelShader);
            if (!debugMaterial) debugMaterial = CreateMaterial(debugShader);

            InitializeBuffers();

            needsReset = false;
        }

        void InitializeBuffers()
        {
            Graphics.Blit(null, positionBuffer2, kernelMaterial, 0);
            Graphics.Blit(null, velocityBuffer2, kernelMaterial, 1);
        }

        void SwapBuffersAndInvokeKernels()
        {
            var tmp = positionBuffer1;
            positionBuffer1 = positionBuffer2;
            positionBuffer2 = tmp;

            tmp = velocityBuffer1;
            velocityBuffer1 = velocityBuffer2;
            velocityBuffer2 = tmp;

            kernelMaterial.SetTexture("_PositionBuffer", positionBuffer1);
            kernelMaterial.SetTexture("_VelocityBuffer", velocityBuffer1);
            Graphics.Blit(null, positionBuffer2, kernelMaterial, 2);

            kernelMaterial.SetTexture("_PositionBuffer", positionBuffer2);
            Graphics.Blit(null, velocityBuffer2, kernelMaterial, 3);
        }

        void OnDestroy()
        {
            if (positionBuffer1) DestroyImmediate(positionBuffer1);
            if (positionBuffer2) DestroyImmediate(positionBuffer2);
            if (velocityBuffer1) DestroyImmediate(velocityBuffer1);
            if (velocityBuffer2) DestroyImmediate(velocityBuffer2);
            if (kernelMaterial) DestroyImmediate(kernelMaterial);
            if (debugMaterial) DestroyImmediate(debugMaterial);
        }

        void Update()
        {
            if (needsReset)
            {
                ResetResources();
            }

            if (Input.GetMouseButtonDown(0))
            {
                InitializeBuffers();
            }

            SwapBuffersAndInvokeKernels();

            if (props == null)
            {
                props = new MaterialPropertyBlock();
            }
            props.SetTexture("_PositionBuffer", positionBuffer2);

            Graphics.DrawMesh(
                mesh, transform.position, transform.rotation,
                material, 0, null, 0, props
            );
        }

        void OnGUI()
        {
            if (debug && Event.current.type.Equals(EventType.Repaint))
            {
                if (debugMaterial && positionBuffer2)
                {
                    var w = positionBuffer2.width;
                    var h = positionBuffer2.height;

                    var rect = new Rect(0, 0, w, h);
                    Graphics.DrawTexture(rect, positionBuffer2, debugMaterial);

                    rect.y += h;
                    Graphics.DrawTexture(rect, velocityBuffer2, debugMaterial);
                }
            }
        }
    }
}