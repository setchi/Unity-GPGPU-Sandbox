using UnityEngine;
using UnityEngine.Rendering;

namespace UnityGpuSandbox.CubeWave
{
    public partial class CubeWave : MonoBehaviour
    {
        [SerializeField]
        Shader kernelShader;
        [SerializeField]
        Shader debugShader;
        [SerializeField]
        Mesh[] shapes = new Mesh[1];
        [SerializeField]
        Material material;
        [SerializeField]
        ShadowCastingMode castShadows;
        [SerializeField]
        bool receiveShadows = false;
        [SerializeField]
        bool debug = false;

        RenderTexture positionBuffer1;
        RenderTexture positionBuffer2;
        Material kernelMaterial;
        Material debugMaterial;
        MaterialPropertyBlock props;
        BulkMesh bulkMesh;

        bool needsReset = true;

        RenderTexture CreateBuffer()
        {
            var width = bulkMesh.CopyCount;
            var height = 320;
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

        void ResetResources()
        {
            if (bulkMesh == null)
            {
                bulkMesh = new BulkMesh(shapes, 320);
            }
            else
            {
                bulkMesh.Rebuild(shapes);
            }

            if (positionBuffer1) DestroyImmediate(positionBuffer1);
            if (positionBuffer2) DestroyImmediate(positionBuffer2);

            positionBuffer1 = CreateBuffer();
            positionBuffer2 = CreateBuffer();

            if (!kernelMaterial) kernelMaterial = CreateMaterial(kernelShader);
            if (!debugMaterial) debugMaterial = CreateMaterial(debugShader);

            InitializeBuffers();

            needsReset = false;
        }

        void InitializeBuffers()
        {
            Graphics.Blit(null, positionBuffer2, kernelMaterial, 0);
        }

        void SwapBuffersAndInvokeKernels()
        {
            var tempPosition = positionBuffer1;
            positionBuffer1 = positionBuffer2;
            positionBuffer2 = tempPosition;

            kernelMaterial.SetTexture("_PositionBuffer", positionBuffer1);
            Graphics.Blit(null, positionBuffer2, kernelMaterial, 1);
        }

        void Update()
        {
            if (needsReset)
            {
                ResetResources();
            }

            SwapBuffersAndInvokeKernels();

            if (props == null)
            {
                props = new MaterialPropertyBlock();
            }
            props.SetTexture("_PositionBuffer", positionBuffer2);

            var mesh = bulkMesh.Mesh;
            var pos = transform.position;
            var rot = transform.rotation;
            var mat = material;
            var uv = new Vector2(0.5f / positionBuffer2.width, 0);

            for (var i = 0; i < positionBuffer2.height; i++)
            {
                uv.y = (0.5f + i) / positionBuffer2.height;
                props.SetVector("_BufferOffset", uv);
                Graphics.DrawMesh(
                    mesh, pos, rot,
                    mat, 0, null, 0, props,
                    castShadows, receiveShadows
                );
            }
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
                }
            }
        }
    }
}